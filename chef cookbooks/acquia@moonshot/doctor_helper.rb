# -*- coding: utf-8 -*-
require 'colorize'

module Moonshot
  DoctorCritical = Class.new(RuntimeError)

  #
  # A series of methods for adding "doctor" checks to a mechanism.
  #
  module DoctorHelper
    def doctor_hook
      run_all_checks
    end

    private

    def run_all_checks
      success = true
      puts
      puts self.class.name.split('::').last
      private_methods.each do |meth|
        begin
          send(meth) if meth =~ /^doctor_check_/
        rescue DoctorCritical
          # Stop running checks in this Mechanism.
          success = false
          break
        rescue => e
          success = false
          print '  ✗ '.red
          puts "Exception while running check: #{e.class}: #{e.message.lines.first}"
          break
        end
      end

      success
    end

    def success(str)
      print '  ✓ '.green
      puts str
    end

    def warning(str, additional_info = nil)
      print '  ? '.yellow
      puts str
      additional_info.lines.each { |l| puts "      #{l}" } if additional_info
    end

    def critical(str, additional_info = nil)
      print '  ✗ '.red
      puts str
      additional_info.lines.each { |l| puts "      #{l}" } if additional_info
      raise DoctorCritical
    end
  end
end
