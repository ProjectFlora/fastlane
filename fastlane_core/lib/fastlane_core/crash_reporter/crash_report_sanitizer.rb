module FastlaneCore
  class CrashReportSanitizer
    class << self
      def sanitize_backtrace(backtrace: nil, type: :unknown)
        if type == :user_error || type == :crash
          # If the crash is from `UI` we only want to include the stack trace
          # up to the point where the crash was initiated.
          # The two stack frames we are dropping are `method_missing` and
          # the call to `crash!` or `user_error!`.
          stack = backtrace.drop(2)
        else
          stack = backtrace
        end

        stack.map do |frame|
          sanitize_string(string: frame)
        end
      end

      def sanitize_string(string: nil)
        string = sanitize_fastlane_gem_path(string: string)
        string = sanitize_gem_home(string: string)
        sanitize_home_dir(string: string)
      end

      private

      def sanitize_home_dir(string: nil)
        string.gsub(Dir.home, '~')
      end

      def sanitize_fastlane_gem_path(string: nil)
        fastlane_path = Gem.loaded_specs['fastlane'].full_gem_path
        return string unless fastlane_path
        string.gsub(fastlane_path, '[fastlane_path]')
      end

      def sanitize_gem_home(string: nil)
        return string unless Gem.dir
        string.gsub(Gem.dir, '[gem_home]')
      end
    end
  end
end
