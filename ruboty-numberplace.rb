require 'namero'

module Ruboty
  module Handlers
    class NumberPlace < Base
      class UserVisibleError < StandardError; end
      class InvalidBoard < StandardError; end
      class TooManyTries < StandardError; end

      on(
         /((?:number[-_]?place)|ナンプレ|なんぷれ)(?:\s+(?<n>\d+))?/i,
         name: 'numberplace',
         description: "Generate number place puzzle",
      )

      def numberplace(message)
        n = message.match_data[:n]&.to_i || 9
        params = parameters(n)
        resp = format gen(**params), **params
        message.reply(resp)
      rescue UserVisibleError => ex
        message.reply ex.message
      end

      private def gen(n:, root_n:, box_count:, initial_filled_counts:, assume_retry_count:)
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
          solver(board).solve
          board, boxes = assume_and_solve(board: board, boxes: boxes) unless board.complete?
          return boxes if board.complete?
        rescue InvalidBoard, TooManyTries
          # suppress
        end
      end

      private def assume_and_solve(board:, boxes:, remain_tries: 30)
        raise TooManyTries if remain_tries == 0

        new_board = board.dup
        new_boxes = boxes.dup

        v = new_board.each_values.reject { |v| v.value }.shuffle.min_by { |v| v.candidates.size }
        new_boxes[v.index] = v.value = v.candidates.sample
        solver(new_board).solve

        return new_board, new_boxes if new_board.complete?

        if has_no_candidates?(new_board)
          new_board = board.dup
          new_boxes = boxes.dup
          new_v = new_board[v.index]
          new_v.candidates.delete(v.value)
          solver(new_board).fill_one_candidate(new_v.index)
          raise InvalidBoard if has_no_candidates?(new_board)
        end

        assume_and_solve(board: new_board, boxes: new_boxes, remain_tries: remain_tries - 1)
      end

      private def solver(board)
        Namero::Solver.new(board, extensions: [Namero::SolverExtensions::CandidateExistsOnlyOnePlace])
      end

      private def has_no_candidates?(board)
        board.each_values.any? { |v| v.candidates.empty? }
      end

      private def parameters(n)
        initial_filled_counts =
          case n
          when 4
            [*4..6] # is it proper?
          when 9
            [*20..28]
          when 16 # 16x16 is too slow
            [*80..90] # is it proper?
          else
            raise UserVisibleError, "not supported N: #{n}"
          end

        {
          n: n,
          root_n: Integer.sqrt(n),
          box_count: n * n,
          initial_filled_counts: initial_filled_counts,
          assume_retry_count: {4 => 0, 9 => 2, 16 => 30},
        }
      end

      private def format(boxes, n:, root_n:, **)
        res = ''
        boxes.each_slice(n).with_index do |line, idx|
          line.each_slice(root_n) do |group|
            group.each do |box|
              res << to_emoji(box)
            end
            res << ' '
          end
          res << "\n"
          res << "\n" if idx % root_n == root_n - 1
        end

        uri = 'https://puzzle.pocke.me/#/number_place_from_param?' +
          URI.encode_www_form(board: JSON.generate(boxes.each_slice(n).to_a))
        res << uri
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
          10 => ':a:',
          11 => ':b:',
          12 => ':c:',
          13 => ':d:',
          14 => ':e:',
          15 => ':f:',
          16 => ':zero:',
          nil => ':transparent2:',
        }[n]
      end
    end
  end
end
