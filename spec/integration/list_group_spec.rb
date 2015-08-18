require 'spec_helper'

describe ListGroup do
  let(:user1)  { FactoryGirl.create(:user) }
  let(:user2)  { FactoryGirl.create(:user) }

  describe "lists" do
    describe "creating a list" do
      it "creates a list group and updates it when subsequent lists are created" do
        list1 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user1)
        list_group = ListGroup.last
        list_group.class.should == ListGroup
        list_group.intralist_id.should == nil
        list_group.list_ids.should == [list1.id]
        list_group.name.should == "Best Hotels in NYC"
        ListGroup.count.should == 1

        list2 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user2)
        ListGroup.count.should == 1
        list_group.reload
        list_group.class.should == ListGroup
        list_group.intralist_id.should == Intralist.first.id
        list_group.list_ids = [list1.id, list2.id]

        list3 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user2)
        ListGroup.count.should == 1
        list_group.reload
        list_group.class.should == ListGroup
        list_group.intralist_id.should == Intralist.first.id
        list_group.list_ids = [list1.id, list2.id, list3.id]

        FactoryGirl.create(:list, :name => "Best Hotels in Chicago", :user => user2)
        ListGroup.count.should == 2
      end

      it "pulls in existing responses with the same name" do
        #because they don't create their own list list group

        request = FactoryGirl.create(:request, :name => "Best Hotels in NYC")
        response = FactoryGirl.create(:response, :name => "Best Hotels in NYC", 
                                      :request => request)
        list = FactoryGirl.create(:list, :name => "Best Hotels in NYC")

        ListGroup.last.list_ids.should == [response.id, list.id]
      end
    end

    describe "updating a list" do
      #should it rename the list group, or create and destroy it?
      describe "renaming a list" do
        it "removes it from the list group and adds it to a new one" do
          #creates or updates that new list group
          list1 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user1)
          list2 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user1)
          list3 = FactoryGirl.create(:list, :name => "Other List", :user => user1)
          list_group = ListGroup.where(:name => "Best Hotels in NYC").first

          list1.name = "Other List"
          list1.save

          list_group.reload
          list_group.list_ids.should == [list2.id]

          list_group = ListGroup.where(:name => "Other List").first
          ListGroup.count.should == 2
          list_group.list_ids.should == [list3.id, list1.id]
        end

        it "deletes the list group if no more lists with that name remain" do
          list1 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user1)
          list_group = ListGroup.last
          list_group.class.should == ListGroup
          list_group.intralist_id.should == nil
          list_group.list_ids.should == [list1.id]
          list1.name = "New Name"
          list1.save

          ListGroup.count.should == 1
          list_group = ListGroup.last
          list_group.name.should == "New Name"
          list_group.class.should == ListGroup
          list_group.intralist_id.should == nil
          list_group.list_ids.should == [list1.id]
        end
      end

      describe "maintaining the same name" do
        it "doesn't create a new list group" do
          list1 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user1)
          list_group = ListGroup.last
          list1.update_list(:items => list1.items)

          list_group.reload
          list_group.name.should == "Best Hotels in NYC"
        end
      end
    end

    describe "deleting a list" do
      it "removes it from the list group" do
        list1 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user1)
        list2 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user2)
        list2.destroy
        list_group = ListGroup.last

        list_group.list_ids = [list1.id]
      end

      it "deletes the list group if no more lists with that name remain" do
        list1 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user1)
        list1.destroy
        ListGroup.count.should == 0
      end
    end
  end

  describe "requests" do
    describe "creating a request" do
      it "creates a list group for each request" do
        request = FactoryGirl.create(:request, :name => "Best Restaurants")
        ListGroup.count.should == 1
        list_group = ListGroup.last
        list_group.request_id.should == request.id
        list_group.name.should == "Best Restaurants"
        list_group.class.should == RequestListGroup

        request = FactoryGirl.create(:request, :name => "Best Restaurants in NYC")
        ListGroup.count.should == 2
        list_group = ListGroup.last
        list_group.request_id.should == request.id
        list_group.name.should == "Best Restaurants in NYC"

        request = FactoryGirl.create(:request, :name => "Best Restaurants in NYC")
        ListGroup.count.should == 3
        list_group = ListGroup.last
        list_group.request_id.should == request.id
        list_group.name.should == "Best Restaurants in NYC"
      end
    end

    describe "updating a request" do
      it "updates the name of the list group" do
        request = FactoryGirl.create(:request, :name => "Best Restaurants")
        ListGroup.count.should == 1
        list_group = ListGroup.first
        list_group.name.should == "Best Restaurants"

        request.update_attributes(:name => "Best Restaurants in NYC")
        ListGroup.count.should == 1
        list_group.reload
        list_group.name.should == "Best Restaurants in NYC"
      end
    end

    describe "deleting a request" do
      it "deletes the list group" do
        request = FactoryGirl.create(:request, :name => "Best Restaurants")
        ListGroup.count.should == 1

        request.destroy
        ListGroup.count.should == 0
      end
    end

    describe "responding to a request" do
      #check intralist id stuff in here
      #needs to remove intralist ids properly as well - everywhere
      describe "creating a response" do
        it "updates the list group by adding subsequent responses to the list group" do
          request = FactoryGirl.create(:request, :name => "Best Restaurants")

          response1 = FactoryGirl.create(:response, :name => "Best Restaurants", :request_id => request.id)
          ListGroup.count.should == 1
          RequestListGroup.count.should == 1
          list_group = ListGroup.last
          list_group.request_id.should == request.id
          list_group.list_ids.should == [response1.id]
          Intralist.count.should == 0
          list_group.intralist_id.should == nil

          response2 = FactoryGirl.create(:response, :name => "Best Restaurants", :request_id => request.id)
          ListGroup.count.should == 1
          list_group.reload
          list_group.list_ids.should == [response1.id, response2.id]
          Intralist.count.should == 1
          list_group.intralist_id.should == Intralist.first.id

          request = FactoryGirl.create(:response, :name => "Best Restaurants")

        end

         it "does not create a new list group if one does not exist" do
           #otherwise the response will show up twice at the top of the feed, assuming they're sorted by updated_at
          request = FactoryGirl.create(:request, :name => "Best Restaurants")
          response = FactoryGirl.create(:response, :name => "Best Restaurants", :request => request)

          ListGroup.count.should == 1
          list_group = ListGroup.last
          list_group.list_ids.should == [response.id]
          list_group.class.should == RequestListGroup
         end

        it "updates an existing list list group with the same name if one exists" do
          #this list item cross references many responses as the 'master item'.
          list = FactoryGirl.create(:list, :name => "Best Restaurants")

          request = FactoryGirl.create(:request, :name => "Best Restaurants")
          response = FactoryGirl.create(:response, :name => "Best Restaurants", :request => request)

          ListGroup.count.should == 2

          request_list_group = RequestListGroup.first
          request_list_group.list_ids.should == [response.id]
          request_list_group.request_id.should == request.id

          response2 = FactoryGirl.create(:response, :name => "Best Restaurants", :request => request)
          request_list_group.reload
          request_list_group.list_ids.should == [response.id, response2.id]
          request_list_group.request_id.should == request.id

          list_list_group = ListGroup.where(:_type => "ListGroup").first
          list_list_group.list_ids.should == [list.id, response.id, response2.id]
        end
      end

      #describe "updating a response"...
      #renaming responses is not currently supported

      describe "deleting a response" do
        it "removes the response ID from all list groups" do #it doesn't delete any list groups
          list = FactoryGirl.create(:list, :name => "Best Restaurants")

          request = FactoryGirl.create(:request, :name => "Best Restaurants")
          response = FactoryGirl.create(:response, :name => "Best Restaurants", :request => request)

          ListGroup.count.should == 2

          response.destroy

          request_list_group = RequestListGroup.first
          request_list_group.list_ids.should == []
          request_list_group.request_id.should == request.id

          list_list_group = ListGroup.where(:_type => "ListGroup").first
          list_list_group.list_ids.should == [list.id]
        end
      end

    end
  end

  #TODO: Test user_ids stuff

end
