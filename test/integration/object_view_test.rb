require 'test_helper'

class ObjectViewTest < ActionDispatch::IntegrationTest
  fixtures :inv_objects, :inv_collections_inv_objects, :inv_collections

  test "view object works" do
    visit(logout_path)
    visit(login_path)
    click_button("Guest")
    click_link("Demo Merritt")
    click_link("ark:/99999/fk40k2sqf")
  end

  test "dua works" do
    visit(logout_path)
    visit(login_path)
    click_button("Guest")
    click_link("Demo Merritt")
    click_link("ark:/99999/fk40k2sqf")
    click_button("Download object")
    # should be sent to dua page
    fill_in('Name', :with => 'Jane Doe')
    fill_in('Affiliation', :with => 'Doe International')
    fill_in('Email', :with => 'doe@mailinator.com')
    check("accept")
    click_button("Accept")
    assert_equal("attachment; filename=ark+=99999=fk40k2sqf_object.zip", page.response_headers["Content-Disposition"])
  end

  test "direct download works without redirect" do
    # visit("/d/ark%3A%2F20775%2Fbb03080025")
  end

  test "authentication works" do
    # api access
    # should be able to download restricted object by supplying credentials via http basic auth
  end
end
