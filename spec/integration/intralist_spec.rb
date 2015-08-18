require 'spec_helper'

describe Intralist do
  let(:user)  { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  describe "creating a list" do
    it "should not create an Intralist if two or more lists of the same name exist and there is no item overlap" do
      list1 = FactoryGirl.create(:list, :name => "best hotels in nyc", :user => user,
                                 :items => [FactoryGirl.build(:item, :name => "item 1"),
                                            FactoryGirl.build(:item, :name => "item 2")])

      Intralist.all.count.should == 0

      list2 = FactoryGirl.create(:list, :name => "best hotels in nyc", :user => user2,
                                 :items => [FactoryGirl.build(:item, :name => "item A"),
                                            FactoryGirl.build(:item, :name => "item B")])
      intralists = Intralist.where(:name => "best hotels in nyc").to_a
      intralists.count.should == 0
    end

    context "creating an intralist" do
      it "creates an intralist if there is another list of the same name and there is list item overlap" do
        list1 = FactoryGirl.create(:list, :name => "best hotels in nyc", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "item 1"),
                                              FactoryGirl.build(:item, :name => "item 2")])
        Intralist.all.count.should == 0

        list2 = FactoryGirl.create(:list, :name => "best hotels in nyc", :user => user2,
                                   :items => [FactoryGirl.build(:item, :name => "item 1"),
                                              FactoryGirl.build(:item, :name => "item 2")])

        intralists = Intralist.where(:name => "best hotels in nyc").to_a
        intralists.count.should == 1

        intralists[0].intralist_items.map(&:count).should == [2, 2]
        intralists[0].intralist_items
          .map { |item| item.contributors }.should =~ [[user.id, user2.id], [user.id, user2.id]]

        list1.reload
        list1.intralist_id.should == intralists[0].id
        list2.reload
        list2.intralist_id.should == intralists[0].id
      end

      it "updates the existing intralist otherwise, adding new items appropriately" do
        FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user)
        FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user)
        list = FactoryGirl.build(:list, :name => "Best Hotels in NYC", :user => user2)
        list.items << FactoryGirl.build(:item, :name => "Item 3")
        list.save

        intralists = Intralist.where(:name => "Best Hotels in NYC").to_a
        intralists.count.should == 1

        intralists[0].intralist_items.map(&:count).should == [3, 3, 1]
        intralists[0].intralist_items.map(&:name).should == ["Item 1", "Item 2", "Item 3"]

        intralists[0].intralist_items
          .map { |item| item.contributors }.should =~ [[user.id, user2.id], [user.id, user2.id], [user2.id]]

        List.all.map(&:intralist_id).uniq.should == [intralists[0].id]
      end

      it "is case insensitive with respect to list and item names" do
        list1 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user)
        list2 = FactoryGirl.create(:list, :name => "best hotels in nyc", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "item 1"),
                                              FactoryGirl.build(:item, :name => "item 2")])

        intralists = Intralist.where(:name => "Best Hotels in NYC").to_a
        intralists.count.should == 1

        intralists[0].intralist_items.map(&:count).should == [2, 2]
        intralists[0].intralist_items
          .map { |item| item.contributors }.should =~ [[user.id], [user.id]]

        list1.reload
        list1.intralist_id.should == intralists[0].id
        list2.reload
        list2.intralist_id.should == intralists[0].id
      end
    end

    context "updating an existing intralist" do
      it "is case insensitive with respect to list names" do
        list1 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user)
        list2 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user)
        list3 = FactoryGirl.create(:list, :name => "best hotels in NYC", :user => user)

        intralists = Intralist.where(:name => "Best Hotels in NYC").to_a
        intralists.count.should == 1
        intralists.first.intralist_items.map(&:count).uniq.should == [3]
      end

      it "is case insensitive with respect to item names" do
        list1 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user)
        list2 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user)
        list3 = FactoryGirl.create(:list, :name => "best hotels in NYC", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "ITEM 1"),
                                              FactoryGirl.build(:item, :name => "ITEM 2")])

        intralists = Intralist.where(:name => "Best Hotels in NYC").to_a
        intralists.count.should == 1
        intralists.first.intralist_items.map(&:count).uniq.should == [3]
      end
    end
  end

  describe "deleting a list" do
    let!(:list1) { FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user) }
    let!(:list2) { FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user2) }
  
    it "reduces intralist item counts if more than one item of that name still exists" do
      list3 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :items =>
                                [FactoryGirl.build(:item, :name => "item 1"),
                                 FactoryGirl.build(:item, :name => "item 2")])
      list3.destroy
  
      intralist = Intralist.where(:name => "Best Hotels in NYC").first
      intralist.intralist_items.map(&:count).should == [2, 2]
      intralist.intralist_items.map(&:name).should == ["Item 1", "Item 2"]
  
      intralist.intralist_items
        .map { |item| item.contributors }.should =~ [[user.id, user2.id], [user.id, user2.id]]
  
      list1.reload
      list1.intralist_id.should == intralist.id
      list2.reload
      list2.intralist_id.should == intralist.id
    end
  
    it "deletes the items from the intralist if no more of that name exist" do
      list3 = FactoryGirl.build(:list, :name => "Best Hotels in NYC")
      list3.items << FactoryGirl.build(:item, :name => "Item 3")
      list3.save
      list3.destroy
  
      intralists = Intralist.where(:name => "Best Hotels in NYC").to_a
      intralists.count.should == 1
      intralists[0].intralist_items.map(&:count).should == [2, 2]
      intralists[0].intralist_items.map(&:name).should == ["Item 1", "Item 2"]
  
      List.all.map(&:intralist_id).uniq.should == [intralists[0].id]
    end
  
    it "deletes the intralist if only one more list will remain" do
      list2.reload
      list2.destroy
  
      list1.reload
      list1.intralist_id.should == nil
  
      Intralist.count.should == 0
    end
  end
  
  #TODO: Finish adding tests for intralist ids
  describe "updating a list" do
    let!(:list1) { FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user).reload }
    let!(:list2) { FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user2).reload }
  
    context "renaming a list" do
      context "a list without an intralist" do
        it "successfully updates" do
          list3 = FactoryGirl.create(:list, :name => "Best Hotels in Miami")
          items = list3.items.map { |item| {:name => item.name, :id => item.id} }
          expect { list3.update_list(:items => items) }.to_not raise_error
        end
      end
  
      context "a list with an intralist" do
        it "reduces intralist item counts if more than one item of that name still exists" do
          list3 = FactoryGirl.create(:list, :name => "Best Hotels in NYC")
          list3.name = "Best Hotels in the USA"
          items = list3.items.map { |item| {:name => item.name, :id => item.id} }
          list3.update_list(:items => items)
  
          intralist = Intralist.where(:name => "Best Hotels in NYC").first
          intralist.intralist_items.map(&:count).should == [2, 2]
  
          intralist.intralist_items
            .map { |item| item.contributors }.should =~ [[user.id, user2.id], [user.id, user2.id]]
  
          list1.reload
          list1.intralist_id.should == intralist.id
          list2.reload
          list2.intralist_id.should == intralist.id
          list3.reload
          list3.intralist_id.should == nil
        end
  
        it "deletes the items from the intralist if no more of that name exist" do
          list3 = FactoryGirl.build(:list, :name => "Best Hotels in NYC")
          list3.items << FactoryGirl.build(:item, :name => "Carlyle")
          list3.save

          list3.name = "Best Hotels in the USA"
          items = list3.items.map { |item| {:name => item.name, :id => item.id} }
          list3.update_list(:items => items)
  
          intralist = Intralist.where(:name => "Best Hotels in NYC").first
          intralist.intralist_items.count.should == 2
  
          list1.reload
          list1.intralist_id.should == intralist.id
          list2.reload
          list2.intralist_id.should == intralist.id
          list3.reload
          list3.intralist_id.should == nil
        end
  
        it "creates a new intralist if appropriate" do
          user3 = FactoryGirl.create(:user)
          list3 = FactoryGirl.create(:list, :name => "Best Hotels in the USA", :user => user3)
          user4 = FactoryGirl.create(:user)
          list4 = FactoryGirl.create(:list, :name => "Best Hotels in NYC", :user => user4)

          list2.name = "Best Hotels in the USA"
          items = list2.items.map { |item| {:name => item.name, :id => item.id} }
          list2.update_list(:items => items)

          Intralist.count.should == 2
          intralist1 = Intralist.where(:name => "Best Hotels in the USA").first.intralist_items
          intralist1.map { |item| item.count }.should =~ [2, 2]

          intralist1.map { |item| item.contributors }.should =~ [[user2.id, user3.id], [user2.id, user3.id]]
          intralist2 =Intralist.where(:name => "Best Hotels in NYC").first.intralist_items
          intralist2.map { |item| item.count }.should =~ [2, 2]
          intralist2.map { |item| item.contributors }.should =~ [[user.id, user4.id], [user.id, user4.id]]
        end

        it "deletes the intralist if only one more list will remain" do
          list2.name = "Best Hotels in the USA"
          items = list2.items.map { |item| {:name => item.name, :id => item.id} }
          list2.update_list(:items => items)

          Intralist.count.should == 0

          list1.reload
          list1.intralist_id.should == nil
        end
      end
    end

    context "updating items without renaming a list" do
      it "deleting an item" do
        list2.update_list(:items => [{:name => list2.items[0].name, :id => list2.items[0].id}]) #try case insensitive

        intralist = Intralist.where(:name => "Best Hotels in NYC").first
        intralist.intralist_items.map(&:name).should == ["Item 1", "Item 2"]
        intralist.intralist_items.map(&:count).should == [2, 1]
        intralist.intralist_items
          .map { |item| item.contributors }.should =~ [[user.id, user2.id], [user.id]]

        list1.reload.intralist_id.should == intralist.id
        list2.reload.intralist_id.should == intralist.id
      end

      it "adding an item" do
        list2.update_list(:items => [
          {:name => list2.items[0].name, :id => list2.items[0].id},
          {:name => list2.items[1].name, :id => list2.items[1].id},
          {:name => "Other Item"}
        ])
        #TODO: try case insensitive

        intralist = Intralist.where(:name => "Best Hotels in NYC").first
        intralist.intralist_items.map(&:name).should == ["Item 1", "Item 2", "Other Item"]
        intralist.intralist_items.map(&:count).should == [2, 2, 1]
        intralist.intralist_items
          .map { |item| item.contributors }.should =~ [[user.id, user2.id], [user.id, user2.id], [user2.id]]
      end

      it "renaming an item" do
        list2.update_list(:items => [
          {:name => list2.items[0].name, :id => list2.items[0].id},
          {:name => "Other Item", :id => list2.items[1].id},
        ])

        intralist = Intralist.where(:name => "Best Hotels in NYC").first
        intralist.intralist_items.map { |item| [item.name, item.count] }.should =~ [["Item 1", 2], ["Item 2", 1], ["Other Item", 1]]
        intralist.intralist_items
          .map { |item| item.contributors }.should =~ [[user.id, user2.id], [user2.id], [user.id]]
      end
    end

    context "updating a list that started an intralist, with an intralist made of 3 lists" do
      #items are not on the intralist
      it "removing an item" do
        list1 = FactoryGirl.create(:list, :name => "Best Letters", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "a"),
                                              FactoryGirl.build(:item, :name => "b")])
        list2 = FactoryGirl.create(:list, :name => "Best Letters", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "c"),
                                              FactoryGirl.build(:item, :name => "d")])
        list3 = FactoryGirl.create(:list, :name => "Best Letters", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "a"),
                                              FactoryGirl.build(:item, :name => "e")])
        list3.reload

        list3.update_list(:items => [
          {:name => list3.items[1].name, :id => list3.items[1].id}
        ])
        Intralist.count.should == 1
      end

      it "renaming an item" do
        list1 = FactoryGirl.create(:list, :name => "Best Letters", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "a"),
                                              FactoryGirl.build(:item, :name => "b")])
        list2 = FactoryGirl.create(:list, :name => "Best Letters", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "c"),
                                              FactoryGirl.build(:item, :name => "d")])
        list3 = FactoryGirl.create(:list, :name => "Best Letters", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "a"),
                                              FactoryGirl.build(:item, :name => "e")])
        list3.reload

        list3.update_list(:items => [
          {:name => list3.items[1].name, :id => list3.items[1].id},
          {:name => "eeee", :id => list3.items[0].id}
        ])
        Intralist.count.should == 1
      end

      it "renaming a list" do
        list1 = FactoryGirl.create(:list, :name => "Best Letters", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "a"),
                                              FactoryGirl.build(:item, :name => "b")])
        list2 = FactoryGirl.create(:list, :name => "Best Letters", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "c"),
                                              FactoryGirl.build(:item, :name => "d")])
        list3 = FactoryGirl.create(:list, :name => "Best Letters", :user => user,
                                   :items => [FactoryGirl.build(:item, :name => "a"),
                                              FactoryGirl.build(:item, :name => "e")])
        list3.reload

        list3.name = "fuck off"

        list3.update_list(:items => [
          {:name => list3.items[0].name, :id => list3.items[0].id},
          {:name => list3.items[1].name, :id => list3.items[1].id}
        ])

        list1.reload.intralist_id.should == nil
        list2.reload.intralist_id.should == nil
        list3.reload.intralist_id.should == nil
        Intralist.count.should == 1
      end

    end
  end
end
