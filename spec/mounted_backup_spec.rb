require_relative '../lib/mounted_backup'

describe MountedBackup do
	let(:mnts) { double("Mounts") }
	let(:rup) { double("Ruplite") }
	let(:mntd_backup) { MountedBackup.new(rup, mnts) }

  before :each do
  	mntd_backup.needs("sda1", "/mnt/drive")
  end

	context "when not mounted" do
		before :each do
			allow(mnts).to receive(:mounted?).and_return(false)
		end

		it "should not call run on the backup" do
			expect(mnts).to receive(:mounted?).with("sda1", "/mnt/drive")
			expect(rup).not_to receive(:run)
			mntd_backup.run
		end
		
	end


end
