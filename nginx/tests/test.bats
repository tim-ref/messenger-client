#!/usr/bin/env bats

setup() {
    bats_require_minimum_version 1.5.0

    load '/bats/test_helper/common-setup'
    _common_setup
}

@test "unknown url fails" {
  run ! curl --fail http://proxy:80/doesNotExist
}

@test "can get vzd token" {
  run -0 curl -v --fail http://proxy:80/vzd-owner-authenticate
}

@test "can parse response location" {
    run bash -c "curl -s http://proxy:80/vzd-owner-authenticate| jq -r -e '.location'"

    echo "Location" $output

    assert_output --regexp '^https://idp-ref.app.ti-dienste.de.*$'
}

@test "can parse response status" {
    run bash -c "curl -s http://proxy:80/vzd-owner-authenticate| jq -r -e '.status'"

    echo "Status" $output

    assert_output '302'
}

@test "response should have content type" {
  run curl -i -s --fail http://proxy:80/dummy.js

  assert_output --regexp "Content-Type: application/javascript"
}

@test "response should have CORS header" {
  run curl -i -s --fail http://proxy:80/vzd-owner-authenticate

  assert_output --regexp "Access-Control-Allow-Origin: *"
}

@test "can access fhir resources via proxy" {
    run curl --fail -v http://proxy:80/vzd/owner-authenticate

    assert_output --regexp "HTTP/1.1 302"
    assert_output --regexp "Location: .*"
}