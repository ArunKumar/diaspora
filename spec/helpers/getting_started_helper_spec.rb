#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require 'spec_helper'

describe GettingStartedHelper do
  before do
    @current_user = alice
  end

  def current_user
    @current_user
  end

  describe "#has_completed_profile?" do
    it 'returns true if the current user has filled out all 7 suggested fields (from getting started)' do
      profile = @current_user.person.profile
      profile.update_attributes!(
        {:first_name => "alice", :last_name => "smith", :image_url => "abcd.jpg", :birthday => Date.new,
         :gender => "cow", :location => "san fran", :tag_string => "#sup", :bio => "holler" })
      has_completed_profile?.should be_true
    end

    it 'returns false if the current user has not filled out all 7 suggested fields (from getting started)' do
      @current_user.update_attributes(:person => {:profile =>
        {:first_name => nil, :last_name => nil, :birthday => nil, :gender => nil }})
      has_completed_profile?.should be_false
    end
  end

  describe "#has_connected_services?" do
    before do
      AppConfig[:configured_services] = ['fake_service']
    end

    it 'returns true if the current user has connected at least one service' do
      @current_user.services << Factory.build(:service)
      has_connected_services?.should be_true
    end

    it 'returns true if the current user has zero connected services and the server has no services configured' do
      AppConfig[:configured_services] = []
      @current_user.services.delete_all
      has_connected_services?.should be_true
    end

    it 'returns false if the current user has not connected any service' do
      @current_user.services.delete_all
      has_connected_services?.should be_false
    end
  end

  describe "#has_few_contacts?" do
    it 'returns true if the current_user has more than 2 contacts' do
      3.times do |n|
        @current_user.contacts << Contact.new(:person => Factory(:person), :receiving => true)
      end
      has_few_contacts?.should be_true
    end

    it 'returns false if the current_user has less than 2 contacts (inclusive)' do
      @current_user.contacts.delete_all
      has_few_contacts?.should be_false
    end
  end

  describe "has_few_followed_tags?" do
    it 'returns true if the current_user has more than 2 contacts' do
      3.times do |n|
        @current_user.followed_tags << ActsAsTaggableOn::Tag.new(:name => "poodles_#{n}")
      end
      has_few_followed_tags?.should be_true
    end

    it 'returns false if the current_user has less than 2 contacts (inclusive)' do
      @current_user.followed_tags.delete_all
      has_few_followed_tags?.should be_false
    end
  end
  
  describe "#has_connected_cubbies?" do
    it 'returns true if the current user has connected cubbies to their account' do
      @current_user.authorizations << Factory(:oauth_authorization)
      has_connected_cubbies?.should be_true
    end

    it 'returns false if the current user has not connected cubbies to their account' do
      has_connected_cubbies?.should be_false
    end
  end

  describe "#has_completed_getting_started?" do
    it 'returns true if the current user has completed getting started' do
      @current_user.getting_started = false
      @current_user.save
      has_completed_getting_started?.should be_true
    end

    it 'returns false if the current user has not completed getting started' do
      @current_user.getting_started = true
      @current_user.save
      has_completed_getting_started?.should be_false
    end
  end

  describe "#welcome_text" do
    it 'returns "Welcome" without a name if first_name is not set' do
      profile = @current_user.person.profile
      profile.first_name = ""
      profile.save
      @current_user.person.instance_variable_set(:@first_name, nil)
      
      welcome_text.should == "Welcome!"
    end

    it 'returns "Welcome, {first_name}" if first_name is set' do
      welcome_text.should == "Welcome, #{current_user.first_name}!"
    end
  end
end
