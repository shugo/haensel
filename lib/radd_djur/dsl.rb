module RaddDjur
  module DSL
    include Immutable

    refine Object do
      def bind(&block)
        to_parser.bind(&block)
      end

      def /(p2)
        to_parser / p2
      end

      def optional
        to_parser.optional
      end

      def zero_or_more
        to_parser.zero_or_more
      end

      def one_or_more
        to_parser.one_or_more
      end

      def to_parser
        raise TypeError, "#{self.class} can't be converted to a Parser"
      end
    end

    refine Symbol do
      def to_parser
        Grammar::Parser.new(&self)
      end
    end

    refine String do
      def to_parser
        Grammar::Parsers.string(self)
      end
    end

    refine Range do
      def to_parser
        Grammar::Parsers.any_char.bind { |c|
          if self.cover?(c)
            Grammar::Parsers.ret(c)
          else
            Grammar::Parsers.fail
          end
        }
      end
    end

    refine Array do
      def bind(&block)
        list = List.from_array(self)
        bind_list(list, List[], block)
      end

      private

      def bind_list(list, args, block)
        if list.empty?
          block.call(*args.reverse.to_a)
        else
          list.head.bind { |x|
            bind_list(list.tail, Cons[x, args], block)
          }
        end
      end
    end
  end
end
