require_relative "../spec_helper"

RSpec.describe Sift::Entities::Label, :with_configs do
  let(:device) { Sift::Device.new(id: 'device_id') }
  let(:label) { Sift::Entities::Label.new(device) }

  describe '#label_bad!' do
    it "will mark device bad" do
      stub_request(:put, label.send(:url))
        .to_return({ body: '{ "label": "bad" }' })

      expect(device.labeled?).to eq(false)

      label.label_bad!
      expect(device.labeled?).to eq(true)
      expect(device.bad?).to eq(true)
    end
  end

  describe '#label_not_bad!' do
    it "will mark device bad" do
      stub_request(:put, label.send(:url))
        .to_return({ body: '{ "label": "not_bad" }' })

      expect(device.labeled?).to eq(false)

      label.label_not_bad!
      expect(device.labeled?).to eq(true)
      expect(device.not_bad?).to eq(true)
    end
  end

  context 'with unlabeled device' do
    let(:device) { Sift::Device.new() }

    it("#bad? returns false") { expect(label.bad?).to eq(false) }
    it("#not_bad? returns false") { expect(label.not_bad?).to eq(false) }
    it("#labeled? returns false") { expect(label.labeled?).to eq(false) }
  end

  context 'with device labeled bad' do
    let(:device) { Sift::Device.new(label: Sift::Entities::Label::BAD) }

    it("#bad? returns true") { expect(label.bad?).to eq(true) }
    it("#not_bad? returns false") { expect(label.not_bad?).to eq(false) }
    it("#labeled? returns true") { expect(label.labeled?).to eq(true) }
  end

  context 'with device labeled not_bad' do
    let(:device) { Sift::Device.new(label: Sift::Entities::Label::NOT_BAD) }

    it("#bad? returns false") { expect(label.bad?).to eq(false) }
    it("#not_bad? returns true") { expect(label.not_bad?).to eq(true) }
    it("#labeled? returns true") { expect(label.labeled?).to eq(true) }
  end
end
