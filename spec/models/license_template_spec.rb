require 'spec_helper'

describe LicenseTemplate do
  describe "get set default demo" do
    context "get default demo" do
      it "has no default demo" do
        lic_template = LicenseTemplate.get_default_demo
        expect(lic_template.license_type).to eq License::DEMO
      end

      it "has default demo" do
        demo_template = create(:demo_license_template)
        LicenseTemplate.set_default_demo(demo_template.id)
        lic_template = LicenseTemplate.get_default_demo
        expect(lic_template.license_type).to eq License::DEMO
        expect(lic_template.expire_days).to eq demo_template.expire_days
        expect(lic_template.name).to eq demo_template.name
      end
    end

    context "set default demo" do
      it "has prev default demo" do
        demo_template = create(:demo_license_template)
        demo_template2 = build(:demo_license_template)
        demo_template2.name = "demo2"
        demo_template2.save
        LicenseTemplate.set_default_demo(demo_template.id)
        expect(LicenseTemplate.get_default_demo.id).to eq demo_template.id
        LicenseTemplate.set_default_demo(demo_template2.id)
        expect(LicenseTemplate.get_default_demo.id).to eq demo_template2.id

      end
      it "has no default demo" do
        demo_template = create(:demo_license_template)
        LicenseTemplate.set_default_demo(demo_template.id)
        expect(LicenseTemplate.get_default_demo.id).to eq demo_template.id
      end
    end

  end


  describe "get set default pro" do
    context "get set default pro" do
      context "get " do
        it "has no default pro" do
          def_pro = LicenseTemplate.get_default_com
          expect(def_pro).to be_nil
        end

        it "has default pro" do
          pro_template = create(:pro_license_template)
          LicenseTemplate.set_default_com(pro_template.id)
          def_pro = LicenseTemplate.get_default_com
          expect(def_pro.name).to eq "pro_license"
        end
      end
    end

  end

  describe "Test counters" do
    #TODO
  end
end
