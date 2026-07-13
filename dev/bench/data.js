window.BENCHMARK_DATA = {
  "lastUpdate": 1783941543046,
  "repoUrl": "https://github.com/VRamakrishna/cacti",
  "entries": {
    "Benchmark": [
      {
        "commit": {
          "author": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "rafael.belchior@tecnico.ulisboa.pt"
          },
          "committer": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "RafaelAPB@users.noreply.github.com"
          },
          "id": "366055e57c984c9323990f605fda445297ada8ed",
          "message": "refactor: remove keychain plugins\n\nAddresses #4025\nSigned-off-by: Rafael Belchior <rafael.belchior@tecnico.ulisboa.pt>",
          "timestamp": "2026-07-06T12:10:15Z",
          "url": "https://github.com/VRamakrishna/cacti/commit/366055e57c984c9323990f605fda445297ada8ed"
        },
        "date": 1783595457128,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 662,
            "range": "±2.72%",
            "unit": "ops/sec",
            "extra": "177 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 663,
            "range": "±2.90%",
            "unit": "ops/sec",
            "extra": "182 samples"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "rafael.belchior@tecnico.ulisboa.pt"
          },
          "committer": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "RafaelAPB@users.noreply.github.com"
          },
          "id": "366055e57c984c9323990f605fda445297ada8ed",
          "message": "refactor: remove keychain plugins\n\nAddresses #4025\nSigned-off-by: Rafael Belchior <rafael.belchior@tecnico.ulisboa.pt>",
          "timestamp": "2026-07-06T12:10:15Z",
          "url": "https://github.com/VRamakrishna/cacti/commit/366055e57c984c9323990f605fda445297ada8ed"
        },
        "date": 1783596256587,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "plugin-ledger-connector-besu_HTTP_GET_getOpenApiSpecV1",
            "value": 935,
            "range": "±3.39%",
            "unit": "ops/sec",
            "extra": "181 samples"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "name": "Bhavyam Sharma",
            "username": "bhavyamsharmaa",
            "email": "positionbhavyamsharma@gmail.com"
          },
          "committer": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "RafaelAPB@users.noreply.github.com"
          },
          "id": "1c1a069a616e426b52814a4cd88791747a47b5ee",
          "message": "fix(cacti-plugin-consortium-static): add jti replay protection\n\n- Add optional seenJtis parameter to verifyOrganization to track used JWT IDs\n- StaticConsortiumRepository owns the Map and passes it on each verifyJWT call\n- Reject tokens missing exp claim; jwtVerify does not require exp to be present\n- Namespace jti cache key as iss:jti to prevent cross-org collisions\n- Replace unbounded Set with Map<string, number> storing jti -> exp;\n  prune expired entries on each verify call\n- Remove buggy manual expiry check (payload.exp seconds vs Date.now() ms\n  mismatch); jose's jwtVerify already throws JWTExpired for expired tokens\n- Remove console.error in catch block; return false for all failures\n- Add unit tests: first-use acceptance, replay rejection, wrong issuer,\n  expired token, no-exp token, cross-org same-jti, no-seenJtis mode\n- Fix linter errors in verifyOrganization\n\nCloses #4372\n\nAssisted-by: anthropic:claude-sonnet-4-6\nSigned-off-by: Bhavyam Sharma <positionbhavyamsharma@gmail.com>",
          "timestamp": "2026-07-10T13:26:07Z",
          "url": "https://github.com/VRamakrishna/cacti/commit/1c1a069a616e426b52814a4cd88791747a47b5ee"
        },
        "date": 1783941093451,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 628,
            "range": "±3.57%",
            "unit": "ops/sec",
            "extra": "175 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 624,
            "range": "±2.13%",
            "unit": "ops/sec",
            "extra": "184 samples"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "name": "Bhavyam Sharma",
            "username": "bhavyamsharmaa",
            "email": "positionbhavyamsharma@gmail.com"
          },
          "committer": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "RafaelAPB@users.noreply.github.com"
          },
          "id": "1c1a069a616e426b52814a4cd88791747a47b5ee",
          "message": "fix(cacti-plugin-consortium-static): add jti replay protection\n\n- Add optional seenJtis parameter to verifyOrganization to track used JWT IDs\n- StaticConsortiumRepository owns the Map and passes it on each verifyJWT call\n- Reject tokens missing exp claim; jwtVerify does not require exp to be present\n- Namespace jti cache key as iss:jti to prevent cross-org collisions\n- Replace unbounded Set with Map<string, number> storing jti -> exp;\n  prune expired entries on each verify call\n- Remove buggy manual expiry check (payload.exp seconds vs Date.now() ms\n  mismatch); jose's jwtVerify already throws JWTExpired for expired tokens\n- Remove console.error in catch block; return false for all failures\n- Add unit tests: first-use acceptance, replay rejection, wrong issuer,\n  expired token, no-exp token, cross-org same-jti, no-seenJtis mode\n- Fix linter errors in verifyOrganization\n\nCloses #4372\n\nAssisted-by: anthropic:claude-sonnet-4-6\nSigned-off-by: Bhavyam Sharma <positionbhavyamsharma@gmail.com>",
          "timestamp": "2026-07-10T13:26:07Z",
          "url": "https://github.com/VRamakrishna/cacti/commit/1c1a069a616e426b52814a4cd88791747a47b5ee"
        },
        "date": 1783941541308,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "plugin-ledger-connector-besu_HTTP_GET_getOpenApiSpecV1",
            "value": 1731,
            "range": "±3.01%",
            "unit": "ops/sec",
            "extra": "178 samples"
          }
        ]
      }
    ]
  }
}