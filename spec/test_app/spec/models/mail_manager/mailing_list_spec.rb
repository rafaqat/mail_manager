require 'rails_helper'

RSpec.describe MailManager::MailingList do
  context "a valid mailing list" do
    before(:each) do
      @mailing_list = FactoryGirl.build(:mailing_list)
    end
    it "must have a name" do 
      expect(@mailing_list.name.present?).to eq true
      expect(@mailing_list.valid?).to eq true
      @mailing_list.name = nil
      expect(@mailing_list.valid?).to eq false
    end
  end
  describe "self::active_email_addresses_contact_ids_subscription_ids_for_mailing_list_ids" do
    it "returns all active email addresses, contact_ids, subscription_ids for given mailing list ids" do
      contact1 = FactoryGirl.create(:contact)
      contact2 = FactoryGirl.create(:contact)
      contact3 = FactoryGirl.create(:contact)
      contact4 = FactoryGirl.create(:contact)
      list1 = FactoryGirl.create(:mailing_list)
      sub1 = contact1.subscribe(list1)
      sub2 = contact2.subscribe(list1)
      list2 = FactoryGirl.create(:mailing_list)
      sub3 = contact2.subscribe(list2)
      sub4 = contact3.subscribe(list2)
      list3 = FactoryGirl.create(:mailing_list)
      sub5 = contact3.subscribe(list3)
      sub6 = contact4.subscribe(list3)
      expect(MailManager::MailingList.
        active_email_addresses_contact_ids_subscription_ids_for_mailing_list_ids(
        [list1.id, list2.id]).sort).to eq (
        {
          contact1.email_address => {
            contact_id: contact1.id,
            subscription_id: sub1.id
          },
          contact2.email_address => {
            contact_id: contact2.id,
            subscription_id: sub2.id
          },
          contact2.email_address => {
            contact_id: contact2.id,
            subscription_id: sub3.id
          },
          contact3.email_address => {
            contact_id: contact3.id,
            subscription_id: sub4.id
          }
        }.sort
      ) 
      and_it "doesn't include soft deleted contacts" do
        contact2.delete
        expect(MailManager::MailingList.
          active_email_addresses_contact_ids_subscription_ids_for_mailing_list_ids(
          [list1.id, list2.id]).sort).to eq (
          {
            contact1.email_address => {
              contact_id: contact1.id,
              subscription_id: sub1.id
            },
            contact3.email_address => {
              contact_id: contact3.id,
              subscription_id: sub4.id
            }
          }.sort
        ) 
      end
    end
  end
end
