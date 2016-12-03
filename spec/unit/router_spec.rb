require_relative "../spec_helper"

require "sift/router"

module Sift
  describe Router do
    describe "#handle_response" do
      it "raises an error when response is a non 200" do
        fake_response = double(code: 300)

        expect {
          Router.handle_response(fake_response)
        }.to raise_error(ApiError)

        begin
          Router.handle_response(fake_response)
        rescue ApiError => e
          expect(e.response).to eq(fake_response)
        end
      end
    end
  end
end


