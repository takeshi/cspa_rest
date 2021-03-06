
function tests(serviceurl, div) {

  test(div, "Check output of test job", function(handler) {
    var job = Job("test1", "/LEL")
      .input( "data"
      	    , serviceurl + "/tests/test1_data.csv"
      	    , serviceurl + "/tests/test1_data_schema.json"
      	    )
      .input( "weights"
            , serviceurl + "/tests/test1_weights.csv"
            )
      .input( "rules"
      	    , serviceurl + "/tests/test1_rules.txt"
      	    );

    expect_equal()
    .on_error(handler)(job, "/LEL/tests/test1_ref.json");
  });

  test(div, "Incorrect column name in data schema", function(handler) {
    var job = Job("test2", "/LEL")
      .input( "data"
            , serviceurl + "/tests/test2_data.csv"
            , serviceurl + "/tests/test2_data_schema.json"
            )
      .input( "rules"
            , serviceurl + "/tests/test2_rules.txt"
            );
    expect_error()
    .on_error(handler)(job);
  });

  test(div, "Empty rule set", function(handler) {
    var job = Job("test3", "/LEL")
      .input("data", serviceurl + "/tests/test3_data.csv", 
        serviceurl + "/tests/test3_data_schema.json")
      .input("rules", serviceurl + "/tests/test3_rules.txt");
    expect_error().on_error(handler)(job);
  });

  test(div, "Check primary key job", function(handler) {
    var job = Job("test4", "/LEL")
      .input( "data"
            , serviceurl + "/tests/test4_data.csv"
            , serviceurl + "/tests/test4_data_schema.json"
            )
      .input( "weights"
            , serviceurl + "/tests/test4_weights.csv"
            )
      .input( "rules"
            , serviceurl + "/tests/test4_rules.txt"
            );

    expect_equal()
    .on_error(handler)(job, "/LEL/tests/test4_ref.json");
  });

}

