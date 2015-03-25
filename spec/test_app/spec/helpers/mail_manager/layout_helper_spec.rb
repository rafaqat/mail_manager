require 'rails_helper'

RSpec.describe MailManager::LayoutHelper, :type => :helper do
  describe "#title" do
    it "translates what you give it and returns when translation exists" do
      expect(helper.title("mail_manager/mailing.edit.title", subject: "Bonkers", 
        default: "Edit my 'Bonkers'")
      ).to eq("<h1>Edit Bonkers</h1>")
      and_it "then returns the same thing ... without the h1 tags on the subsequent call" do
        expect(helper.title).to eq "Edit Bonkers"
      end
    end
    it "translates to your default when your translation name doesn't exist" do
      expect(helper.title("my.nonsense.title", subject: "Bonkers", 
        default: "Edit my 'Bonkers'")
      ).to eq("<h1>Edit my 'Bonkers'</h1>")
      and_it "then returns the same thing ... without the h1 tags on the subsequent call" do
        expect(helper.title).to eq "Edit my 'Bonkers'"
      end
    end
  end
  describe "#site_url" do
    it "returns the mail manager's site_url setting as a helper" do
      expect{helper.site_url}.not_to raise_error
      expect(helper.site_url).to eq(MailManager.site_url)
    end
  end
  describe "#show_title?" do
    it "returns the mail manager's show_title setting as a helper" do
      expect{helper.show_title?}.not_to raise_error
      expect(helper.show_title?).to eq(MailManager.show_title)
    end
  end
  describe "#use_show_for_resources?" do
    it "returns the mail manager's use_show_for_resources setting as a helper" do
      expect{helper.use_show_for_resources?}.not_to raise_error
      expect(helper.use_show_for_resources?).to eq(MailManager.use_show_for_resources)
    end
  end
  
end
