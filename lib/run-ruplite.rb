require './ruplite'
require 'logger'

src = '/home/bobg/icon'
tgt = 'file:///home/bobg/backups/test'
log = Logger.new(STDOUT)

opts = []
opts << '--encrypt-key 87909562'
opts << '--sign-key 31894F89'

config = {:source => src, :target => tgt, :options => opts}
config[:passphrase] = 'xxx'

#test = Ruplite.new('Test', config)
test = Ruplite.new('Test', config, log)

#puts test.run
test.run

