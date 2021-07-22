R and rmarkdown files for miscellaneous functions, survival functions, data documentation and a graphical user interface


* server.R and ui.R

    * R scripts for shiny server
    
* utilities.R

   * helper functions
   
* log_data_summary.rmd

   * R markdown to generate reproducible reports for data documentation

* log_model_summary.rmd and

   * R markdown to generate reproducible reports for model documentation

* model_cards.rmd

   * R markdown for model cards
   
* redmeat_survival_ownVM.R

   * script to load data and perform filtering and quality control in DataSHIELD 

* harmonization.R

   * script to perform harmonization

* harmonization_testing.R

   * framework to perform testing of harmonization Java code

   * also see

        * https://github.com/neelsoumya/dsHarmoniseClient/blob/main/dslite_harm.R

* synthetic_data_generator.R

   * framework to generate synthetic data

   * also see

        * https://github.com/neelsoumya/dsSynthetic

* data_gen.R

   * Code using Gaussian cupola to generate synthetic data

* stage1.R and stage2.R and combiner.R

   * script to call servers sequentially and not in parallel for fault tolerant computing

* ds_profiler.R

   * profiler for Cox functions

   * also see

        * https://github.com/neelsoumya/dsProfiler
