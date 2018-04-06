# Sift Science Ruby bindings [![Build Status](https://travis-ci.org/SiftScience/sift-ruby.png?branch=master)](https://travis-ci.org/SiftScience/sift-ruby)

## Requirements

  * Ruby 1.9.3 or above.


## Installation

If you want to build the gem from source:

```
$ gem build sift.gemspec
```

Alternatively, you can install the gem from rubygems.org:

```
gem install sift
```

## Usage

### Creating a Client:

```ruby
require "sift"

Sift.api_key = '<your_api_key_here>'
Sift.account_id = '<your_account_id_here>'
client = Sift::Client.new()

##### OR

client = Sift::Client.new(api_key: '<your_api_key_here>', account_id: '<your_account_id_here>'

```

### Sending a transaction event

```ruby
event = "$transaction"

user_id = "23056"  # User ID's may only contain a-z, A-Z, 0-9, =, ., -, _, +, @, :, &, ^, %, !, $

properties = {
 "$user_id" => user_id,
  "$user_email" => "buyer@gmail.com",
  "$seller_user_id" => "2371",
  "seller_user_email" => "seller@gmail.com",
  "$transaction_id" => "573050",
  "$payment_method" => {
    "$payment_type"    => "$credit_card",
    "$payment_gateway" => "$braintree",
    "$card_bin"        => "542486",
    "$card_last4"      => "4444"
  },
  "$currency_code" => "USD",
  "$amount" => 15230000,
}

response = client.track(event, properties)

response.ok?  # returns true or false
response.body  # API response body
response.http_status_code  # HTTP response code, 200 is ok.
response.api_status  # status field in the return body, Link to Error Codes
response.api_error_message  # Error message associated with status Error Code

# Request a score for the user with user_id 23056
response = client.score(user_id)
```

## Decisions

To learn more about the decisions endpoint visit our [developer docs](https://siftscience.com/developers/docs/ruby/decisions-api/get-decisions).

### List of Configured Decisions

Get a list of your decisions.

**Optional Params**
 - `entity_type`: `:user` or `:order` or `:session` or `:content`
 - `abuse_types`: `["payment_abuse", "content_abuse", "content_abuse",
   "account_abuse", "legacy", "account_takeover"]`

**Returns**

A `Response` object

**Example:**
```ruby
# fetch a list of all your decisions
response = client.decisions({
  entity_type: :user,
  abuse_types: ["payment_abuse", "content_abuse"]
})

# Check that response is okay.
unless response.ok?
  raise "Unable to fetch decisions #{response.api_error_message} " +
    "#{response.api_error_description}"
end

# find a decisions with the id "block_bad_user"
user_decision = response.body["data"].find do |decision|
  decision["id"] == "block_bad_user"
end

# Get the next page

if response.body["has_more"]
  client.decisions(response.body)
end
```


### Apply a decision

Applies a decision to an entity. Visit our [developer docs](http://siftscience.com/developers/docs/ruby/decisions-api/apply-decision) for more information.

**Required Params:**
- `decision_id`, `source`, `user_id`

**Other Params**
- `order_id`: when applying a decision to an order, you must pass in the `order_id`
- `session_id`: when applying a decision to a session, you must pass in the `session_id`
- `analyst`: when `source` is set to `manual_review`, this field *is required*

**Returns**
`Response` object.

**Examples:**
```ruby
# apply decision to a user
response = client.apply_decision({
  decision_id: "block_bad_user",
  source: "manual_review",
  analyst: "bob@your_company.com",
  user_id: "john@example.com"
})

# apply decision to "john@example.com"'s order
response = client.apply_decision({
  decision_id: "block_bad_order",
  source: "manual_review",
  analyst: "bob@your_company.com",
  user_id: "john@example.com",
  order_id: "ORDER_1234"
})

# apply decision to "john@example.com"'s session
response = client.apply_decision({
  decision_id: "block_bad_session",
  source: "manual_review",
  analyst: "bob@your_company.com",
  user_id: "john@example.com",
  session_id: "SESSION_ID_1234"
})

# apply decision to "john@example.com"'s content
response = client.apply_decision({
  decision_id: "block_bad_session",
  source: "manual_review",
  analyst: "bob@your_company.com",
  user_id: "john@example.com",
  content_id: "CONTENT_ID_1234"
})


# Make sure you handle the response after applying a decision:

if response.ok?
  # do stuff
else
  # Error message
  response.api_error_message

  # Summary of the error
  response.api_error_description

  # hash of errors:
  #  key: field in question
  #  value: description of the issue
  response.api_error_issues
end
```

## Sending a Label

```ruby
# Label the user with user_id 23056 as Bad with all optional fields
response = client.label(user_id, {
  "$is_bad" => true,
  "$abuse_type" => "payment_abuse",
  "$description" => "Chargeback issued",
  "$source" => "Manual Review",
  "$analyst" => "analyst.name@your_domain.com"
})

# Get the status of a workflow run
response = client.get_workflow_status('my_run_id')

# Get the latest decisions for a user
response = client.get_user_decisions('example_user_id')

# Get the latest decisions for an order
response = client.get_order_decisions('example_order_id')

# Get the latest decisions for an content
response = client.get_content_decisions('example_user_id', 'example_order_id')
```

## Response Object

All requests to our apis will return a `Response` instance.

### Public Methods:
- `ok?` returns `true` when the response is a `200`-`299`, `false` if it isn't
- `body` returns a hash representation of the json body returned.
- `api_error_message` returns a string describing the api error code.
- `api_error_description` a summary of the error that occured.
- `api_error_issues` a hash describing the items the error occured. The `key` is the item and the `value` is the description of the error.


## Building

Building and publishing the gem is captured by the following steps:

```ruby
$ gem build sift.gemspec
$ gem push sift-<current version>.gem

$ bundle
$ rake -T
$ rake build
$ rake install
$ rake release
```


## Testing

To run the various tests use the rake command as follows:

```ruby
$ rake spec
```
