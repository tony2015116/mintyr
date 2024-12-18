# WARNING - Generated by {fusen} from dev/flat_teaching.Rmd: do not edit by hand

test_that("top_perc functions correctly", {
  # Setup test data
  set.seed(123)
  test_data <- data.frame(
    id = 1:100,
    group = rep(c("A", "B"), each = 50),
    value = rnorm(100, mean = 10, sd = 2),
    score = runif(100, 0, 100)
  )
  
  # Test basic functionality
  test_that("basic functionality works", {
    # Test with single percentage
    result1 <- top_perc(test_data, perc = 0.1, trait = "value")
    expect_true(is.data.frame(result1))
    expect_equal(nrow(result1), 1)
    expect_true(all(c("variable", "n", "mean", "sd", "top_perc") %in% names(result1)))
    
    # Test with multiple percentages
    result2 <- top_perc(test_data, perc = c(0.1, 0.2), trait = "value")
    expect_equal(nrow(result2), 2)
    expect_equal(result2$top_perc, c("10%", "20%"))
  })
  
  # Test grouping functionality
  test_that("grouping works correctly", {
    result <- top_perc(test_data, perc = 0.1, trait = "value", by = "group")
    expect_equal(nrow(result), 2)  # One row per group
    expect_true("group" %in% names(result))
    
    # Test multiple grouping variables
    test_data$subgroup <- rep(c("X", "Y"), 50)
    result_multi <- top_perc(test_data, perc = 0.1, trait = "value", by = c("group", "subgroup"))
    expect_equal(nrow(result_multi), 4)  # 2 groups × 2 subgroups
  })
  
  # Test keep_data parameter
  test_that("keep_data parameter works", {
    result <- top_perc(test_data, perc = 0.1, trait = "value", keep_data = TRUE)
    expect_true(is.list(result))
    expect_true(all(c("stat", "data") %in% names(result[[1]])))
    expect_true(is.data.frame(result[[1]]$data))
    expect_true(is.data.frame(result[[1]]$stat))
    
    # Check data size
    expect_equal(nrow(result[[1]]$data), ceiling(nrow(test_data) * 0.1))
  })
  
  # Test different summary types
  test_that("summary types work correctly", {
      result_mean_sd <- top_perc(test_data, perc = 0.1, trait = "value", type = "mean_sd")
      result_median_iqr <- top_perc(test_data, perc = 0.1, trait = "value", type = "median_iqr")
      
      expect_true(all(c("mean", "sd") %in% names(result_mean_sd)))
      expect_true(all(c("median", "iqr") %in% names(result_median_iqr)))
    })
    
  # Test error handling
  test_that("error handling works correctly", {
      # Missing arguments
      expect_error(top_perc(perc = 0.1, trait = "value"), "Missing argument.*data")
      expect_error(top_perc(data = test_data, trait = "value"), "Missing argument.*perc")
      expect_error(top_perc(data = test_data, perc = 0.1), "Missing argument.*trait")
      
      # Invalid perc values
      expect_error(top_perc(test_data, perc = 1.5, trait = "value"),
                   "must be.*between -1 and 1")
      expect_error(top_perc(test_data, perc = -1.5, trait = "value"),
                   "must be.*between -1 and 1")
      
      # Invalid trait
      expect_error(top_perc(test_data, perc = 0.1, trait = "nonexistent"),
                   "must be a valid column name")
      expect_error(top_perc(test_data, perc = 0.1, trait = c("value", "score")),
                   "must be a single character string")
      
      # Invalid by
      expect_error(top_perc(test_data, perc = 0.1, trait = "value", by = "nonexistent"),
                   "must be valid column names")
      expect_error(top_perc(test_data, perc = 0.1, trait = "value", by = 1),
                   "must be a character vector")
    })
    
  # Test data type handling
  test_that("handles different data types correctly", {
      # Test with data.table
      dt_data <- data.table::as.data.table(test_data)
      result_dt <- top_perc(dt_data, perc = 0.1, trait = "value")
      expect_true(is.data.frame(result_dt))
      
      # Test with tibble
      tbl_data <- tibble::as_tibble(test_data)
      result_tbl <- top_perc(tbl_data, perc = 0.1, trait = "value")
      expect_true(is.data.frame(result_tbl))
    })
    
  # Test edge cases
  test_that("edge cases are handled correctly", {
      # Test with 100% selection
      result_all <- top_perc(test_data, perc = 1, trait = "value")
      expect_equal(nrow(result_all), 1)
      
      # Test with very small percentage
      result_min <- top_perc(test_data, perc = 0.01, trait = "value")
      expect_equal(nrow(result_min), 1)
      
      # Test with NA values
      test_data_na <- test_data
      test_data_na$value[1:10] <- NA
      result_na <- top_perc(test_data_na, perc = 0.1, trait = "value")
      expect_true(!is.na(result_na$n))
    })
    
  # Test result consistency
  test_that("results are consistent", {
      # Test that top percentage actually contains top values
      result <- top_perc(test_data, perc = 0.1, trait = "value", keep_data = TRUE)
      top_values <- result[[1]]$data$value
      all_values <- test_data$value
      
      expect_true(min(top_values) >= quantile(all_values, 0.9, na.rm = TRUE))
      
      # Test that grouping preserves correct proportions
      result_grouped <- top_perc(test_data, perc = 0.1, trait = "value", 
                                 by = "group", keep_data = TRUE)
      for (group in unique(test_data$group)) {
        group_data <- result_grouped[[paste0("value_0.1")]]$data
        group_count <- sum(group_data$group == group)
        expect_equal(group_count, ceiling(sum(test_data$group == group) * 0.1))
      }
    })
    })
