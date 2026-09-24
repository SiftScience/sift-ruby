#!/usr/bin/env ruby
# NEB-4783 QA self-serve check, section D (client libraries) - Ruby.
#
# IMPORTANT: none of the 6 client library PRs (Java, .NET, Python, PHP, Ruby) are merged
# or released yet. This only works against a local checkout of this branch - installing
# the published sift-ruby gem will NOT have these fields.
#
# The Ruby client does zero field validation - it's a thin pass-through that serialises
# whatever hash you give it. So there's no "compile-time safety" story here like
# Java/.NET; this script only proves the round trip against prod actually works.
#
# How to run:
#   SIFT_QA_API_KEY=... ruby structured_fields_self_serve_check.rb
#
# Needs Ruby >= 2.7 (this gemspec's own requirement). If your system `ruby` is older
# (check with `ruby --version`), install a newer one via Homebrew and use its path
# instead, e.g. SIFT_QA_API_KEY=... /opt/homebrew/opt/ruby/bin/ruby structured_fields_self_serve_check.rb
#
# Each call reuses the exact payload shapes already verified in section A's Postman
# collection. All 7 should print "api_status: 0" - if any doesn't, that's a real finding.

require_relative "lib/sift"

USER_ID = "qa_structured_fields_2026"
ORDER_ID = "qa_order_001"

api_key = ENV["SIFT_QA_API_KEY"]
raise "Set SIFT_QA_API_KEY first - see the comment at the top of this file." if api_key.nil? || api_key.empty?

client = Sift::Client.new(api_key: api_key, account_id: USER_ID)

def check(client, label, event, properties)
  response = client.track(event, properties)
  puts "[#{label}] http_status_code=#{response.http_status_code} " \
       "api_status=#{response.api_status} " \
       "api_error_message=#{response.api_error_message}"
  if response.api_status != 0 || response.http_status_code != 200
    puts "[#{label}] UNEXPECTED - expected api_status 0 / http 200"
  end
end

check(client, "create_account", "$create_account", {
  "$user_id" => USER_ID,
  "$nationality" => "US",
  "$year_of_birth" => 1985,
  "$kyc" => {
    "$names_match" => true,
    "$kyc_level" => "$basic",
    "$bin_nationality_match" => true,
    "$provider" => "lexisnexis"
  },
  "$geo" => { "$uuid" => "gc-abc-123", "$provider" => "geocomply" },
  "$bot_identification" => { "$result" => "$human", "$provider" => "datadome" }
})

check(client, "update_account", "$update_account", {
  "$user_id" => USER_ID,
  "$nationality" => "US",
  "$year_of_birth" => 1985,
  "$kyc" => {
    "$names_match" => true,
    "$kyc_level" => "$full",
    "$bin_nationality_match" => true,
    "$provider" => "lexisnexis"
  },
  "$geo" => { "$uuid" => "gc-abc-123", "$provider" => "geocomply" },
  "$bot_identification" => { "$result" => "$human", "$provider" => "datadome" }
})

check(client, "login", "$login", {
  "$user_id" => USER_ID,
  "$login_status" => "$success",
  "$geo" => { "$uuid" => "gc-abc-123", "$provider" => "geocomply" },
  "$bot_identification" => { "$result" => "$human", "$provider" => "datadome" }
})

check(client, "transaction", "$transaction", {
  "$user_id" => USER_ID,
  "$amount" => 15230000,
  "$currency_code" => "USD",
  "$kyc" => {
    "$names_match" => true,
    "$kyc_level" => "$full",
    "$bin_nationality_match" => false,
    "$provider" => "prove"
  },
  "$geo" => { "$uuid" => "gc-abc-123", "$provider" => "geocomply" },
  "$bot_identification" => { "$result" => "$human", "$provider" => "human_security" }
})

check(client, "create_order", "$create_order", {
  "$user_id" => USER_ID,
  "$order_id" => ORDER_ID,
  "$kyc" => {
    "$names_match" => true,
    "$kyc_level" => "$basic",
    "$bin_nationality_match" => true,
    "$provider" => "lexisnexis"
  },
  "$geo" => { "$uuid" => "gc-abc-123", "$provider" => "geocomply" },
  "$bot_identification" => { "$result" => "$human", "$provider" => "datadome" }
})

check(client, "update_order", "$update_order", {
  "$user_id" => USER_ID,
  "$order_id" => ORDER_ID,
  "$kyc" => {
    "$names_match" => true,
    "$kyc_level" => "$basic",
    "$bin_nationality_match" => true,
    "$provider" => "lexisnexis"
  },
  "$geo" => { "$uuid" => "gc-abc-123", "$provider" => "geocomply" },
  "$bot_identification" => { "$result" => "$human", "$provider" => "datadome" }
})

# No $geo/$bot_identification here on purpose - $verification only supports $kyc per
# the attachment matrix.
check(client, "verification", "$verification", {
  "$user_id" => USER_ID,
  "$verification_type" => "$kyc",
  "$status" => "$success",
  "$kyc" => {
    "$names_match" => true,
    "$kyc_level" => "$basic",
    "$bin_nationality_match" => false,
    "$provider" => "lexisnexis"
  }
})
