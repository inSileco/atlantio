# atlantis_check results print

    Code
      print(check_init(path, mock_groups()))
    Message
      0 errors, 2 warnings, 0 notes.
      ! init.nc Refractory_detritus_N (unset): 3 of 5 cells unset: Atlantis uses the
        fill value 2000 there (values set: 50 to 50).
      ! init.nc Cyano_N (sisters): typical value 1e+05, x2000 the median of its
        sisters (50; Diatom_N and Flagellate_N).

---

    Code
      print(check_prm(bio = run))
    Message
      v No problem found.

