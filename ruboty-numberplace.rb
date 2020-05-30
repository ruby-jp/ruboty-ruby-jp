require 'namero'

module Ruboty
  module Handlers
    class NumberPlace < Base
      on(
         /(number[-_]?place)|ナンプレ|なんぷれ/i,
         name: 'numberplace',
         description: "Generate number place puzzle",
      )

      def numberplace(message)
        message.reply format gen
      end

      N = 3
      N2 = N*N
      BOX_COUNT = N2*N2
      INITIAL_FILLED_COUNTS = [*20..30]

      def gen
        boxes = BOX_COUNT.times.map{nil}

        INITIAL_FILLED_COUNTS.sample.times do
          pos = rand(BOX_COUNT)
          redo if boxes[pos]

          x = pos / N2
          y = pos % N2

          value = rand(N2) + 1

          # same line
          redo if boxes[pos - y, N2].any?{|v| v == value}
          # same column
          redo if y.step(by: N2, to: BOX_COUNT).any?{|i| boxes[i] == value}
          # same block
          block_topleft = (x / N * N * N2) + (y / N * N)
          redo if N.times.any? {|i| boxes[block_topleft + N2 * i, N].any?{|v| v == value} }

          boxes[pos] = value
        end

        board = Namero::Board.load_from_array(boxes, N2)
        Namero::Solver.new(board, extensions: [Namero::SolverExtensions::CandidateExistsOnlyOnePlace]).solve
        return boxes if board.complete?
        gen
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
