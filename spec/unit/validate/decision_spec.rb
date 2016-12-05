require_relative "../../spec_helper"

require "sift/validate/decision"

module Sift
  module Validate
    describe Decision do
      describe "#valid_user?" do
        it "will return true" do
        end
      end

      describe "#valid_order?" do
        it "will return true with valid configs" do
          validator = Decision.new(
            order_id: "order_foo_bar_12354",
            user_id: "hello world",
            source: :hello_world,
            analyst: "asdfsadf@heyo.com"
          )

          expect(validator.valid_order?).to be(true)
        end

        context "with invalid params:" do
          it "user_id, will return false" do
            validator = Decision.new(order_id: "asfasdf")
            expect(validator.valid_order?).to be(false), "nil user is valid"

            validator = Decision.new(order_id: "asfasdf", user_id: {})
            expect(validator.valid_order?).to be(false), "user hash is valid"

            validator = Decision.new(order_id: "asfasdf", user_id: /werwer/)
            expect(validator.valid_order?).to be(false), "regex user is valid"
          end

          it "order_id, will return false" do
            validator = Decision.new(user_id: 1235)
            expect(validator.valid_order?).to be(false)

            validator = Decision.new(user_id: 1235, order_id: {})
            expect(validator.valid_order?).to be(false)

            validator = Decision.new(user_id: 1235, order_id: /23424/)
            expect(validator.valid_order?).to be(false)
          end
        end
      end

      describe "#errors" do
        it "will return a hash describing the validation errors" do
          validator = Decision.new

          error_message = "#{Primitive::ERROR_MESSAGES[:string_or_number]}, got NilClass"

          validator.valid_order?
          expect(validator.errors).to eq({
            order_id: ["order_id #{error_message}"],
            user_id: ["user_id #{error_message}"]
          })
        end
      end
    end
  end
end
