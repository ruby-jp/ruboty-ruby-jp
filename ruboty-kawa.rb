module Ruboty
  module Handlers
    class Kawa < Base
      on(
        /kawa/i,
         name: 'kawa',
         description: 'ちょっと川の様子みてくる',
      )

      def kawa(message)
        message.reply <<~KAWA
          http://cam.wni.co.jp/houraibashi/camera.jpg
          http://cam.wni.co.jp/taikobashi/camera.jpg
          http://www.kasen-suibo.metro.tokyo.jp/img/im/suiiGraph_2B14_1.gif
        KAWA
      end
    end
  end
end
