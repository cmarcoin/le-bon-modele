require "test_helper"

class StripePackSyncTest < ActiveSupport::TestCase
  FakeProduct = Struct.new(:id, keyword_init: true)
  FakePrice = Struct.new(:id, :active, :unit_amount, :currency, keyword_init: true)

  setup do
    @pack = Pack.create!(
      slug: "starter-pack",
      name: "Starter Pack",
      objective: "Identifier le modele",
      description: "Description",
      price_cents: 5_900,
      currency: "eur",
      duration_minutes: 45,
      icon_path: "/reference-assets/icons/starter-pack.svg",
      accent_class: "text-brand-accent"
    )
    ENV["STRIPE_SECRET_KEY"] = "sk_test_123"

    created_prices = []
    @created_prices_ref = -> { created_prices }
    @original_product_create = Stripe::Product.method(:create)
    @original_product_update = Stripe::Product.method(:update)
    @original_product_retrieve = Stripe::Product.method(:retrieve)
    @original_price_create = Stripe::Price.method(:create)
    @original_price_retrieve = Stripe::Price.method(:retrieve)
    @original_price_update = Stripe::Price.method(:update)

    Stripe::Product.define_singleton_method(:create) { |_params| FakeProduct.new(id: "prod_new") }
    Stripe::Product.define_singleton_method(:update) { |id, _params| FakeProduct.new(id:) }
    Stripe::Product.define_singleton_method(:retrieve) { |_id| raise Stripe::InvalidRequestError.new("missing", "id") }
    Stripe::Price.define_singleton_method(:create) do |params|
      price = FakePrice.new(id: "price_#{created_prices.size + 1}", active: true, unit_amount: params[:unit_amount], currency: params[:currency])
      created_prices << price
      price
    end
    Stripe::Price.define_singleton_method(:retrieve) { |_id| raise Stripe::InvalidRequestError.new("missing", "id") }
    Stripe::Price.define_singleton_method(:update) { |id, _params| FakePrice.new(id:, active: false, unit_amount: 5_900, currency: "eur") }
  end

  teardown do
    Stripe::Product.define_singleton_method(:create, @original_product_create)
    Stripe::Product.define_singleton_method(:update, @original_product_update)
    Stripe::Product.define_singleton_method(:retrieve, @original_product_retrieve)
    Stripe::Price.define_singleton_method(:create, @original_price_create)
    Stripe::Price.define_singleton_method(:retrieve, @original_price_retrieve)
    Stripe::Price.define_singleton_method(:update, @original_price_update)
    ENV.delete("STRIPE_SECRET_KEY")
  end

  test "creates stripe product and price for a pack" do
    StripePackSync.sync!(@pack)

    @pack.reload
    assert_equal "prod_new", @pack.stripe_product_id
    assert_equal "price_1", @pack.stripe_price_id
  end

  test "creates a new price when amount changes" do
    @pack.update!(stripe_product_id: "prod_existing", stripe_price_id: "price_existing")

    Stripe::Product.define_singleton_method(:retrieve) { |_id| FakeProduct.new(id: "prod_existing") }
    Stripe::Price.define_singleton_method(:retrieve) { |_id| FakePrice.new(id: "price_existing", active: true, unit_amount: 5_900, currency: "eur") }

    @pack.update!(price_cents: 6_900)
    StripePackSync.sync!(@pack)

    @pack.reload
    assert_equal "prod_existing", @pack.stripe_product_id
    assert_equal "price_1", @pack.stripe_price_id
  end
end
