require "spec_helper"

module Interactor
  describe Context do
    describe ".build" do
      it "converts the given hash to a context" do
        context = Context.build(foo: "bar")

        expect(context).to be_a(Context)
        expect(context).to eq(foo: "bar")
      end

      it "builds an empty context if no hash is given" do
        context = Context.build

        expect(context).to be_a(Context)
        expect(context).to eq({})
      end

      it "doesn't affect the original hash" do
        hash = { foo: "bar" }
        context = Context.build(hash)

        expect(context).to be_a(Context)
        expect {
          context[:foo] = "baz"
        }.not_to change {
          hash[:foo]
        }
      end

      it "preserves an already built context" do
        context1 = Context.build(foo: "bar")
        context2 = Context.build(context1)

        expect(context2).to be_a(Context)
        expect {
          context2[:foo] = "baz"
        }.to change {
          context1[:foo]
        }.from("bar").to("baz")
      end
    end

    describe "#initialize" do
      it "defaults to empty" do
        expect {
          expect(Context.new).to eq({})
        }.not_to raise_error
      end
    end

    describe "#[]" do
      it "maintains indifferent access" do
        require "active_support/hash_with_indifferent_access"

        context = Context.build(HashWithIndifferentAccess.new(foo: "bar"))

        expect(context[:foo]).to eq("bar")
        expect(context["foo"]).to eq("bar")
      end
    end

    describe "#success?" do
      let(:context) { Context.build }

      it "is true by default" do
        expect(context.success?).to eq(true)
      end
    end

    describe "#failure?" do
      let(:context) { Context.build }

      it "is false by default" do
        expect(context.failure?).to eq(false)
      end
    end

    describe "#succeed!" do
      let(:context) { Context.build(foo: "bar") }

      it "sets success to true" do
        context.fail!

        expect {
          context.succeed!
        }.to change {
          context.success?
        }.from(false).to(true)
      end

      it "sets failure to true" do
        context.fail!

        expect {
          context.succeed!
        }.to change {
          context.failure?
        }.from(true).to(false)
      end

      it "preserves success" do
        expect {
          context.succeed!
        }.not_to change {
          context.success?
        }
      end

      it "preserves the context" do
        expect {
          context.succeed!
        }.not_to change {
          context[:foo]
        }
      end

      it "updates the context" do
        expect {
          context.succeed!(foo: "baz")
        }.to change {
          context[:foo]
        }.from("bar").to("baz")
      end

      it "returns the context" do
        expect(context.succeed!).to eq(context)
      end
    end

    describe "#fail!" do
      let(:context) { Context.build(foo: "bar") }

      it "sets success to false" do
        expect {
          context.fail!
        }.to change {
          context.success?
        }.from(true).to(false)
      end

      it "sets failure to true" do
        expect {
          context.fail!
        }.to change {
          context.failure?
        }.from(false).to(true)
      end

      it "preserves failure" do
        context.fail!

        expect {
          context.fail!
        }.not_to change {
          context.failure?
        }
      end

      it "preserves the context" do
        expect {
          context.fail!
        }.not_to change {
          context[:foo]
        }
      end

      it "updates the context" do
        expect {
          context.fail!(foo: "baz")
        }.to change {
          context[:foo]
        }.from("bar").to("baz")
      end

      it "returns the context" do
        expect(context.fail!).to eq(context)
      end
    end
  end
end
