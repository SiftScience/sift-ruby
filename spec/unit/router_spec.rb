require_relative "../spec_helper"

require "sift/router"

module Sift
  describe Router do
    let(:path) { "https://example.com" }
    let(:body) { { question: "Do you wanna go ball?" } }

    describe ".get" do
      it "with a successful request will return a response object" do
        stub_request(:get, path)
          .with(body: MultiJson.dump(body))
          .to_return(body: MultiJson.dump({ cool: true }))

        response = Router.get(path, { body: body })

        expect(response.ok?).to be(true)
        expect(response.body["cool"]).to be(true)
      end

      it "with an unsuccessful request will return a response object" do
        stub_request(:get, path)
          .with(body: MultiJson.dump(body))
          .to_return(body: MultiJson.dump({ cool: false}), status: 403)

        response = Router.get(path, { body: body })

        expect(response.ok?).to be(false)
        expect(response.body["cool"]).to be(false)
      end

    end
  end
end


