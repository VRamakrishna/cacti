window.BENCHMARK_DATA = {
  "lastUpdate": 1787561670140,
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
        "date": 1784197054051,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 652,
            "range": "±2.89%",
            "unit": "ops/sec",
            "extra": "180 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 659,
            "range": "±2.94%",
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
        "date": 1784197375347,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "plugin-ledger-connector-besu_HTTP_GET_getOpenApiSpecV1",
            "value": 742,
            "range": "±40.27%",
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
        "date": 1784545548709,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 853,
            "range": "±3.00%",
            "unit": "ops/sec",
            "extra": "179 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 877,
            "range": "±2.35%",
            "unit": "ops/sec",
            "extra": "180 samples"
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
        "date": 1784545730092,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "plugin-ledger-connector-besu_HTTP_GET_getOpenApiSpecV1",
            "value": 884,
            "range": "±3.34%",
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
        "date": 1784802944430,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 634,
            "range": "±3.12%",
            "unit": "ops/sec",
            "extra": "175 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 649,
            "range": "±2.04%",
            "unit": "ops/sec",
            "extra": "183 samples"
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
        "date": 1784803480767,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "plugin-ledger-connector-besu_HTTP_GET_getOpenApiSpecV1",
            "value": 866,
            "range": "±3.38%",
            "unit": "ops/sec",
            "extra": "179 samples"
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
        "date": 1785152051578,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 603,
            "range": "±2.71%",
            "unit": "ops/sec",
            "extra": "176 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 607,
            "range": "±2.04%",
            "unit": "ops/sec",
            "extra": "183 samples"
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
        "date": 1785152526664,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "plugin-ledger-connector-besu_HTTP_GET_getOpenApiSpecV1",
            "value": 898,
            "range": "±3.49%",
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
        "date": 1785407911580,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 586,
            "range": "±3.96%",
            "unit": "ops/sec",
            "extra": "176 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 652,
            "range": "±2.36%",
            "unit": "ops/sec",
            "extra": "182 samples"
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
        "date": 1785408441716,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "plugin-ledger-connector-besu_HTTP_GET_getOpenApiSpecV1",
            "value": 811,
            "range": "±4.03%",
            "unit": "ops/sec",
            "extra": "175 samples"
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
        "date": 1785757193656,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 630,
            "range": "±2.94%",
            "unit": "ops/sec",
            "extra": "176 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 661,
            "range": "±1.91%",
            "unit": "ops/sec",
            "extra": "183 samples"
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
        "date": 1786013322590,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 588,
            "range": "±3.22%",
            "unit": "ops/sec",
            "extra": "177 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 677,
            "range": "±2.39%",
            "unit": "ops/sec",
            "extra": "183 samples"
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
        "date": 1786013879260,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "plugin-ledger-connector-besu_HTTP_GET_getOpenApiSpecV1",
            "value": 886,
            "range": "±4.51%",
            "unit": "ops/sec",
            "extra": "182 samples"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "name": "VRamakrishna",
            "username": "VRamakrishna",
            "email": "vramakr2@in.ibm.com"
          },
          "committer": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "RafaelAPB@users.noreply.github.com"
          },
          "id": "9195eccc0a1b81112107e3e5be325c85efb95b72",
          "message": "build(deps): updated vulnerable decompress package\n\nAddresses critical dependabot alert #3745.\nReplaced \"decompress\" npm package with \"@xhmikosr/decompress@11.1.3\".\n\nSigned-off-by: VRamakrishna <vramakr2@in.ibm.com>",
          "timestamp": "2026-08-06T12:59:22Z",
          "url": "https://github.com/VRamakrishna/cacti/commit/9195eccc0a1b81112107e3e5be325c85efb95b72"
        },
        "date": 1786354559229,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 590,
            "range": "±3.61%",
            "unit": "ops/sec",
            "extra": "176 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 605,
            "range": "±2.23%",
            "unit": "ops/sec",
            "extra": "182 samples"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "name": "VRamakrishna",
            "username": "VRamakrishna",
            "email": "vramakr2@in.ibm.com"
          },
          "committer": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "RafaelAPB@users.noreply.github.com"
          },
          "id": "9195eccc0a1b81112107e3e5be325c85efb95b72",
          "message": "build(deps): updated vulnerable decompress package\n\nAddresses critical dependabot alert #3745.\nReplaced \"decompress\" npm package with \"@xhmikosr/decompress@11.1.3\".\n\nSigned-off-by: VRamakrishna <vramakr2@in.ibm.com>",
          "timestamp": "2026-08-06T12:59:22Z",
          "url": "https://github.com/VRamakrishna/cacti/commit/9195eccc0a1b81112107e3e5be325c85efb95b72"
        },
        "date": 1786613325204,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 578,
            "range": "±3.19%",
            "unit": "ops/sec",
            "extra": "173 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 609,
            "range": "±1.95%",
            "unit": "ops/sec",
            "extra": "181 samples"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "name": "VRamakrishna",
            "username": "VRamakrishna",
            "email": "vramakr2@in.ibm.com"
          },
          "committer": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "RafaelAPB@users.noreply.github.com"
          },
          "id": "9195eccc0a1b81112107e3e5be325c85efb95b72",
          "message": "build(deps): updated vulnerable decompress package\n\nAddresses critical dependabot alert #3745.\nReplaced \"decompress\" npm package with \"@xhmikosr/decompress@11.1.3\".\n\nSigned-off-by: VRamakrishna <vramakr2@in.ibm.com>",
          "timestamp": "2026-08-06T12:59:22Z",
          "url": "https://github.com/VRamakrishna/cacti/commit/9195eccc0a1b81112107e3e5be325c85efb95b72"
        },
        "date": 1786956652422,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 602,
            "range": "±3.15%",
            "unit": "ops/sec",
            "extra": "174 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 610,
            "range": "±2.08%",
            "unit": "ops/sec",
            "extra": "181 samples"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "name": "VRamakrishna",
            "username": "VRamakrishna",
            "email": "vramakr2@in.ibm.com"
          },
          "committer": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "RafaelAPB@users.noreply.github.com"
          },
          "id": "9195eccc0a1b81112107e3e5be325c85efb95b72",
          "message": "build(deps): updated vulnerable decompress package\n\nAddresses critical dependabot alert #3745.\nReplaced \"decompress\" npm package with \"@xhmikosr/decompress@11.1.3\".\n\nSigned-off-by: VRamakrishna <vramakr2@in.ibm.com>",
          "timestamp": "2026-08-06T12:59:22Z",
          "url": "https://github.com/VRamakrishna/cacti/commit/9195eccc0a1b81112107e3e5be325c85efb95b72"
        },
        "date": 1787215649807,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 631,
            "range": "±3.03%",
            "unit": "ops/sec",
            "extra": "174 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 650,
            "range": "±2.02%",
            "unit": "ops/sec",
            "extra": "182 samples"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "name": "VRamakrishna",
            "username": "VRamakrishna",
            "email": "vramakr2@in.ibm.com"
          },
          "committer": {
            "name": "Rafael Belchior",
            "username": "RafaelAPB",
            "email": "RafaelAPB@users.noreply.github.com"
          },
          "id": "9195eccc0a1b81112107e3e5be325c85efb95b72",
          "message": "build(deps): updated vulnerable decompress package\n\nAddresses critical dependabot alert #3745.\nReplaced \"decompress\" npm package with \"@xhmikosr/decompress@11.1.3\".\n\nSigned-off-by: VRamakrishna <vramakr2@in.ibm.com>",
          "timestamp": "2026-08-06T12:59:22Z",
          "url": "https://github.com/VRamakrishna/cacti/commit/9195eccc0a1b81112107e3e5be325c85efb95b72"
        },
        "date": 1787561668043,
        "tool": "benchmarkjs",
        "benches": [
          {
            "name": "cmd-api-server_HTTP_GET_getOpenApiSpecV1",
            "value": 642,
            "range": "±3.57%",
            "unit": "ops/sec",
            "extra": "179 samples"
          },
          {
            "name": "cmd-api-server_gRPC_GetOpenApiSpecV1",
            "value": 646,
            "range": "±2.82%",
            "unit": "ops/sec",
            "extra": "181 samples"
          }
        ]
      }
    ]
  }
}