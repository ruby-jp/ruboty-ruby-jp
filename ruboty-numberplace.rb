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
        message.reply <<~MSG
          ```
          #{format gen}
          ```
        MSG
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

        board = Namero::Board.load_from_string(format_for_namero(boxes), N2)
        Namero::Solver.new(board, extensions: [Namero::SolverExtensions::CandidateExistsOnlyOnePlace]).solve
        return boxes if board.complete?
        gen
      end

      def format_for_namero(boxes)
        res = ''
        boxes.each_slice(N2) do |line|
          line.each do |box|
            res << (box ? box.to_s : '.')
          end
          res << "\n"
        end
        res
      end

      def format(boxes)
        res = ''
        boxes.each_slice(N2).with_index do |line, lineno|
          left, middle, right =
            if lineno == 0
              ['┏', '┳', '┓']
            else
              ['┣', '╋', '┫']
            end
          res << left
          res << (('━' + middle) * (N2-1)) << '━' << right << "\n" << "┃"

          line.each do |box|
            if box
              res << box.to_s << ' '
            else
              res << '  '
            end
            res << "┃"
          end
          res << "\n"
        end

        res << '┗' << ('━┻' * (N2-1)) << '━' << '┛'
        res
      end
    end
  end
end
