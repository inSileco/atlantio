# print method works for empty Atlantis object

    Code
      print(atlantis_obj)
    Message
      
      -- Atlantis Model --
      
      -- Data availability: 
      x Geometry (BGM)
      x Biology parameters
      x Group file
      x Main output
      x Diet data
      x Detailed diet data
      x Biomass (system-wide)
      x Biomass (per box)
      x Biomass (per age)

# print method shows correct status for populated object

    Code
      print(atlantis_obj)
    Message
      
      -- Atlantis Model --
      
      -- Data availability: 
      v Geometry (BGM)
      v Biology parameters
      x Group file
      x Main output
      x Diet data
      x Detailed diet data
      x Biomass (system-wide)
      x Biomass (per box)
      x Biomass (per age)
      
      -- Geometry details: 
      * 5 boxes (including 0 boundary boxes)
    Condition
      Warning in `mean.default()`:
      argument is not numeric or logical: returning NA
    Message
      * mean depth: NA m

# print method shows geometry details when available

    Code
      print(atlantis_obj)
    Message
      
      -- Atlantis Model --
      
      -- Data availability: 
      v Geometry (BGM)
      x Biology parameters
      x Group file
      x Main output
      x Diet data
      x Detailed diet data
      x Biomass (system-wide)
      x Biomass (per box)
      x Biomass (per age)
      
      -- Geometry details: 
      * 10 boxes (including 0 boundary boxes)
    Condition
      Warning in `mean.default()`:
      argument is not numeric or logical: returning NA
    Message
      * mean depth: NA m

# print method shows main output details when available

    Code
      print(atlantis_obj)
    Message
      
      -- Atlantis Model --
      
      -- Data availability: 
      x Geometry (BGM)
      x Biology parameters
      x Group file
      v Main output
      x Diet data
      x Detailed diet data
      x Biomass (system-wide)
      x Biomass (per box)
      x Biomass (per age)
      
      -- Main output details: 
      * 3 variables
      * 100 time steps

# print method handles complex object with multiple data types

    Code
      print(atlantis_obj)
    Message
      
      -- Atlantis Model --
      
      -- Data availability: 
      v Geometry (BGM)
      v Biology parameters
      v Group file
      x Main output
      v Diet data
      x Detailed diet data
      v Biomass (system-wide)
      x Biomass (per box)
      x Biomass (per age)
      
      -- Group details: 
      * 2 groups
      * 0 group types
      * 0 predators
      
      -- Geometry details: 
      * 15 boxes (including 0 boundary boxes)
    Condition
      Warning in `mean.default()`:
      argument is not numeric or logical: returning NA
    Message
      * mean depth: NA m

