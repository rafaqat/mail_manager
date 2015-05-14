require 'rails_helper'

RSpec.describe MailManager::Message do
  def message
    @message
  end
  context "A Message" do
  before(:each) do 
    @message = FactoryGirl.create(:message)
  end
  describe "concerning statuses" do
    it "starts in :pending" do
      expect(message.status).to eq('pending')
    end
    it "goes to 'sent' on a deliver" do
      message.save
      message.deliver
      expect(message.status).to eq('sent')
    end
    it "goes to 'failed_address' on a message bounce" do
      pending "need to get a failed worthy bounce!"
      raise "not tested"
    end
    it "stays 'sent' on a temporary message bounce" do
      pending "need to get a temporary bounce!"
      raise "not tested"
    end
    it "goes to 'processing' while it is being sent" do
      pending "figure this out... its in the middle of a deliver"
      raise "not tested"
    end
    describe "and can't be delivered unless it is currently pending or ready" do
      it "when pending can be delivered" do
        expect(message.can_deliver?).to be true
      end
      it "when ready can be delivered" do
        message.change_status('ready')
        expect(message.can_deliver?).to be true
      end
      it "when processing cannot be delivered" do
        message.change_status('processing')
        expect(message.can_deliver?).to be false
      end
      it "when sent cannot be delivered" do
        message.change_status('sent')
        expect(message.can_deliver?).to be false
      end
      it "when failed cannot be delivered" do
        message.change_status('failed')
        expect(message.can_deliver?).to be false
      end
    end
  end

  it "has a email_address_with_name when a name is present on the contact" do
    contact = message.contact
    expect(message.email_address_with_name).to eq(%Q|"#{contact.full_name}" <#{contact.email_address}>|)
    and_it "only has email when the contact has no name" do
      message.contact.update_attributes(first_name: nil, last_name: nil)
      expect(message.email_address_with_name).to eq(contact.email_address)
    end
  end

  it "knows its mailing's subject" do
    expect(message.subject).to eq(message.mailing.subject)
  end

  it "knows its contact's full name" do
    expect(message.full_name).to eq(message.contact.full_name)
  end

  context "concerning a deleted contact" do
    before(:each) do
      @contact = MailManager::Contact.find(message.contact_id)
      @contact.delete
      @message = MailManager::Message.find(message.id)
    end
    it "doesn't blow up when asking for full_name" do
      expect(message.full_name).to eq @contact.full_name
    end
    it "doesn't blow up when asking for email_address" do
      expect(message.email_address).to eq @contact.email_address
    end
  end

  context "concerning a nil contact" do
    before(:each) do
      MailManager::Contact.where(id: message.contact_id).delete_all
      @message = MailManager::Message.find(message.id)
    end
    it "doesn't blow up when asking for full_name" do
      expect(message.full_name).to eq nil
    end
    it "doesn't blow up when asking for email_address" do
      expect(message.email_address).to eq nil
    end
  end

  describe "concerning a contact's data" do 
    it "will substitute values into messages" do
      pending "not tested" 
      raise "not tested"
    end
  end

  describe "concerning a registerd contactable's data" do 
    it "will substitute values into messages" do
      pending "not tested" 
      raise "not tested"
    end
  end
  end

  describe "self::email_address_hash_for_mailing_id" do
    it "returns a hash of emails based on a mailing's messages" do
      contact1 = FactoryGirl.create(:contact)
      contact2 = FactoryGirl.create(:contact)
      contact3 = FactoryGirl.create(:contact)
      list1 = FactoryGirl.create(:mailing_list)
      contact1.subscribe(list1)
      contact2.subscribe(list1)
      mailing = FactoryGirl.create(:mailing)
      mailing.mailing_lists << list1
      mailing.initialize_messages
      expect([contact1,contact2].map(&:email_address).sort).to eq(
        MailManager::Message.email_address_hash_for_mailing_id(mailing.id).keys.sort
      )
    end
  end

end
