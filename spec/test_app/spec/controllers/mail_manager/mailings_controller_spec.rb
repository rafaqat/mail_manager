require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe MailManager::MailingsController, :type => :controller do
  render_views
  routes {MailManager::Engine.routes}

  # This should return the minimal set of attributes required to create a valid
  # MailManager::Mailing. As you add validations to MailManager::Mailing, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    FactoryGirl.attributes_for(:mailing)
  }

  let(:invalid_attributes) {
    FactoryGirl.attributes_for(:mailing, subject: nil)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MailManager::MailingsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all mailings as @mailings" do
      mailing = MailManager::Mailing.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:mailings)).to eq([mailing])
      expect(response.body).to have_content("Listing Mailings")
    end
  end

  describe "GET #show" do
    it "assigns the requested mailing as @mailing" do
      mailing = MailManager::Mailing.create! valid_attributes
      get :show, {:id => mailing.to_param}, valid_session
      expect(assigns(:mailing)).to eq(mailing)
      expect(response.body).to have_content(mailing.subject)
    end
  end

  describe "GET #new" do
    it "assigns a new mailing as @mailing" do
      get :new, {}, valid_session
      expect(assigns(:mailing)).to be_a_new(MailManager::Mailing)
      expect(response.body).to have_content("New Mailing")
    end
  end

  describe "GET #edit" do
    it "assigns the requested mailing as @mailing" do
      mailing = MailManager::Mailing.create! valid_attributes
      get :edit, {:id => mailing.to_param}, valid_session
      expect(assigns(:mailing)).to eq(mailing)
      expect(response.body).to have_content("Edit #{mailing.subject}")
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new MailManager::Mailing" do
        expect {
          post :create, {:mailing => valid_attributes}, valid_session
        }.to change(MailManager::Mailing, :count).by(1)
      end

      it "assigns a newly created mailing as @mailing" do
        post :create, {:mailing => valid_attributes}, valid_session
        expect(assigns(:mailing)).to be_a(MailManager::Mailing)
        expect(assigns(:mailing)).to be_persisted
      end

      it "redirects to the mailings list" do
        post :create, {:mailing => valid_attributes}, valid_session
        expect(response).to redirect_to(mailings_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved mailing as @mailing" do
        post :create, {:mailing => invalid_attributes}, valid_session
        expect(assigns(:mailing)).to be_a_new(MailManager::Mailing)
      end

      it "re-renders the 'new' template" do
        post :create, {:mailing => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        FactoryGirl.attributes_for(:mailing)
      }

      it "updates the requested mailing" do
        mailing = MailManager::Mailing.create! valid_attributes
        put :update, {:id => mailing.to_param, :mailing => new_attributes}, valid_session
        mailing = MailManager::Mailing.find(mailing.id)
        expect(mailing).to match_attributes(new_attributes)
      end

      it "assigns the requested mailing as @mailing" do
        mailing = MailManager::Mailing.create! valid_attributes
        put :update, {:id => mailing.to_param, :mailing => valid_attributes}, valid_session
        expect(assigns(:mailing)).to eq(mailing)
      end

      it "redirects to the mailing" do
        mailing = MailManager::Mailing.create! valid_attributes
        put :update, {:id => mailing.to_param, :mailing => valid_attributes}, valid_session
        expect(response).to redirect_to(mailings_path)
      end
    end

    context "with invalid params" do
      it "assigns the mailing as @mailing" do
        mailing = MailManager::Mailing.create! valid_attributes
        put :update, {:id => mailing.to_param, :mailing => invalid_attributes}, valid_session
        expect(assigns(:mailing)).to eq(mailing)
      end

      it "re-renders the 'edit' template" do
        mailing = MailManager::Mailing.create! valid_attributes
        put :update, {:id => mailing.to_param, :mailing => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested mailing" do
      mailing = MailManager::Mailing.create! valid_attributes
      expect {
        delete :destroy, {:id => mailing.to_param}, valid_session
      }.to change(MailManager::Mailing, :count).by(-1)
    end

    it "redirects to the mailings list" do
      mailing = MailManager::Mailing.create! valid_attributes
      delete :destroy, {:id => mailing.to_param}, valid_session
      expect(response).to redirect_to(mailings_url)
    end
  end

end
