require 'namero'

module Ruboty
  module Handlers
    class NumberPlace < Base
      on(
         /((?:number[-_]?place)|ナンプレ|なんぷれ)(?:\s+(?<n>\d+))?/i,
         name: 'numberplace',
         description: "Generate number place puzzle",
      )

      def numberplace(message)
        n = message.match_data[:n]&.to_i || 9
        message.reply format gen(**parameters(n))
      end

      N = 3
      N2 = N*N
      BOX_COUNT = N2*N2
      INITIAL_FILLED_COUNTS = [*20..30]

      def gen(n:, root_n:, box_count:, initial_filled_counts:)
        loop do
          boxes = box_count.times.map{nil}

          initial_filled_counts.sample.times do
            pos = rand(box_count)
            redo if boxes[pos]

            x = pos / n
            y = pos % n

            value = rand(n) + 1

            # same line
            redo if boxes[pos - y, n].any?{|v| v == value}
            # same column
            redo if y.step(by: n, to: box_count).any?{|i| boxes[i] == value}
            # same block
            block_topleft = (x / root_n * root_n * n) + (y / root_n * root_n)
            redo if root_n.times.any? {|i| boxes[block_topleft + n * i, root_n].any?{|v| v == value} }

            boxes[pos] = value
          end

          board = Namero::Board.load_from_array(boxes, n)
          Namero::Solver.new(board, extensions: [Namero::SolverExtensions::CandidateExistsOnlyOnePlace]).solve
          return boxes if board.complete?
        end
      end

      def parameters(n)
        initial_filled_counts =
          case n
          when 4
            [*4..6] # is it proper?
          when 9
            [*20..30]
          when 16
            [*70..90] # is it proper?
          else
            raise "not supported N: #{n}"
          end

        {
          n: n,
          root_n: Integer.sqrt(n),
          box_count: n * n,
          initial_filled_counts: initial_filled_counts,
        }
      end

      def format(boxes)
        res = ''
        boxes.each_slice(N2).with_index do |line, idx|
          line.each_slice(N) do |group|
            group.each do |box|
              res << to_emoji(box)
            end
            res << ' '
          end
          res << "\n"
          res << "\n" if idx % N == N - 1
        end
        res
      end

      def to_emoji(n)
        {
          1 => ':one:',
          2 => ':two:',
          3 => ':three:',
          4 => ':four:',
          5 => ':five:',
          6 => ':six:',
          7 => ':seven:',
          8 => ':eight:',
          9 => ':nine:',
          nil => ':transparent2:',
        }[n]
      end
    end
  end
end
