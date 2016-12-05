require_relative "../../spec_helper"

require "sift/validate/primitive"

module Sift
  module Validate
    describe Primitive do
      describe ".non_empty_string" do
        it "will return nil for valid values" do
          expect(Primitive.non_empty_string("foobar")).to be_nil
        end

        it "will return an error message" do
          [nil, 1, /asdfasdf/].each do |value|
            expect(Primitive.non_empty_string(value)).to(
              eq(Primitive::ERROR_MESSAGES[:non_empty_string]),
              "#{value} is a valid non-empty string"
            )
          end

          expect(Primitive.non_empty_string("")).to(
            eq(Primitive.send(:empty_string_message, :non_empty_string))
          )
        end
      end

      describe ".is_numeric" do
        it "will return nil for numeric values" do
          [1, 29.01, 29 ** 1992848499198, -2].each do |value|
            expect(Primitive.numeric(value)).to(
              be_nil,
              "#{value} is a non numeric value"
            )
          end
        end

        it "will return an error message for non numeric values" do
          ["foobar", nil, :hello_world, {}].each do |value|
            expect(Primitive.numeric(value)).to(
              be(Primitive::ERROR_MESSAGES[:numeric]),
              "#{value} is a numeric value"
            )
          end
        end
      end

      describe ".is_string_or_number?" do
        it "will return nil for numeric or strings" do
          [1234, "asdfasdf", "1234_asdfsdf"].each do |value|
            expect(Primitive.string_or_number(value)).to(
              be_nil,
              "#{value} is a non numeric value"
            )
          end
        end

        it "will return an error message for any other type" do
          [{}, [], :hello_world, nil].each do |value|
            error_message = "#{Primitive::ERROR_MESSAGES[:string_or_number]}," \
                            " got #{value.class}"

            expect(Primitive.string_or_number(value)).to eq(error_message)
          end

          error_message = "#{Primitive::ERROR_MESSAGES[:string_or_number]}, " \
                          "got an empty string"
          expect(Primitive.string_or_number("")).to eq(error_message)
        end
      end
    end
  end
end

