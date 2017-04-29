# Bankscrap::Sabadell

[Bankscrap](https://github.com/bankscrap/bankscrap) adapter for Sabadell.

Bankscrap adapter for Banc Sabadell (Banco Sabadell): business and individual accounts.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bankscrap-sabadell'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bankscrap-sabadell

## Usage

### From terminal
#### Bank account balance

    $ bankscrap balance Sabadell --credentials=user:YOUR_USER --password:YOUR_PASSWORD --login_type:business|individual


#### Transactions

    $ bankscrap transactions Sabadell --credentials=user:YOUR_USER --password:YOUR_PASSWORD --login_type:business|individual

---

For more details on usage instructions please read [Bankscrap readme](https://github.com/bankscrap/bankscrap/#usage).

### From Ruby code

```ruby
require 'bankscrap-sabadell'
sabadell = Bankscrap::Sabadell::Bank.new(user: YOUR_USER, password: YOUR_PASSWORD, login_type: :business) # or :individual
```


## Contributing

1. Fork it ( https://github.com/bankscrap/bankscrap-sabadell/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
