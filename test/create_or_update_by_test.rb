require File.dirname(__FILE__) + '/test_helper.rb'

class CreateOrUpdateByTest < Test::Unit::TestCase
  load_schema

#  t.string :name
#  t.integer :counter
#  t.float :weight
#  t.decimal :price
#  t.datetime :last_poop
#  t.timestamp :created_at, :updated_at

  class CoubTest < ActiveRecord::Base
  end

  def setup
    CoubTest.destroy_all
  end

  def test_ARbase_has_methods
    assert_respond_to CoubTest, :create_or_update
    assert_respond_to CoubTest, :create_or_update_by
    #assert_respond_to CoubTest, :create_or_update_by_price     # dynamic methods don't respond to respond_to ...
    assert_respond_to CoubTest, :create_or_update_by_and
    #assert_respond_to CoubTest, :create_or_update_by_name_and_last_poop
  end

  def test_create_1_on_empty_db
    CoubTest.destroy_all
    c = CoubTest.create_or_update_by( :name, { :name => "John Doe", :counter => 5, :price => 2.2 } )
    assert_equal [c], CoubTest.all
  end

  def test_should_update_existing_and_keep_values
    CoubTest.destroy_all
    c = CoubTest.create_or_update_by( :name, { :name => "John Doe", :counter => 5, :price => 2.2 } )
    count = CoubTest.count
    assert_not_nil c1 = CoubTest.find_by_name("John Doe")
    assert_not_nil c2 = CoubTest.create_or_update_by( :name, { :name => "John Doe", :counter => 2, :weight => 1.6e-5 } )
    assert_equal count, CoubTest.count
    assert_equal c2.id, c1.id
    assert_not_equal c2.counter, c1.counter
    assert_equal 2, c2.counter
    assert_equal 1.6e-5, c2.weight
    assert_equal 2.2, c2.price
  end

  def test_should_create_1_new_on_nonmatch
    CoubTest.destroy_all
    c1 = CoubTest.create_or_update_by( :name, { :name => "John Doe", :counter => 5, :price => 2.2 } )
    assert_equal 1, CoubTest.count
    assert_not_nil c2 = CoubTest.create_or_update_by( :name, { :name => "Jane Doe", :counter => 2, :weight => 1.6e-5 } )
    assert_equal 2, CoubTest.count
    assert_equal c1, CoubTest.find_by_name("John Doe")
    assert_equal c2, CoubTest.find_by_name("Jane Doe")
  end

  def test_coub_duplicate_should_change_first_record
    c1 = CoubTest.create [
      { :name => "John Doe", :counter => 5, :price => 2.2,                  :last_poop => 5.years.ago },
      { :name => "John Doe", :counter => 1, :price => 4.3, :weight => 76.1, :last_poop => nil }
    ]
    c2 = CoubTest.create_or_update_by_name :name => "John Doe", :price => 1.5
    assert_nil c2.weight          # should be the first created record
    assert_not_nil c2.last_poop   # should be the first created record
  end


  def test_mm_create_by_and
    CoubTest.destroy_all
    c1 = CoubTest.create_or_update_by_name :name => "John Doe", :counter => 5, :price => 2.2
    assert_equal 1, CoubTest.count
    c2 = CoubTest.create_or_update_by_name :name => "Jane Doe", :counter => 5, :price => 2.2
    assert_equal 2, CoubTest.count
    c3 = CoubTest.create_or_update_by_price :name => "Jane Wonka", :counter => 2, :price => 2.2
    assert_equal 2, CoubTest.count

    d1 = CoubTest.create_or_update_by_name_and_price :name => "Jane Wonka", :counter => 2, :price => 2.3
    assert_equal 3, CoubTest.count
    assert_equal 2, CoubTest.find_all_by_price(2.2).size
    assert_equal 1, CoubTest.find_all_by_price(2.3).size
  end

  def test_mm_block
    CoubTest.destroy_all
    c1 = CoubTest.create_or_update_by_weight do |c|
      c.name = "John Doe"
      c.weight = 71.5
      c.last_poop = 2.days.ago
    end

  end

end
