/* eslint-disable @typescript-eslint/no-explicit-any */
import { CustomContainer } from "../..";
import { FormControl, InputLabel, MenuItem, Select } from "@mui/material";

const LocationMenu = ({
  location,
  theater,
  handleLocationSelect,
  handleTheaterSelect,
  locationList,
  theaterList,
}: any) => {
  return (
    <CustomContainer>
      <FormControl
        variant="standard"
        sx={{ m: 1, minWidth: 120, width: "100%" }}
      >
        <InputLabel id="demo-simple-select-standard-label">Location</InputLabel>
        <Select
          labelId="demo-simple-select-standard-label"
          id="demo-simple-select-standard"
          value={location}
          onChange={handleLocationSelect}
          label="Location"
        >
          {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
          {locationList
            ? locationList.map((item: any) => (
                <MenuItem key={item} value={item}>
                  {item}
                </MenuItem>
              ))
            : null}
        </Select>
      </FormControl>
      <FormControl
        variant="standard"
        sx={{ m: 1, minWidth: 120, width: "100%" }}
      >
        <InputLabel id="demo-simple-select-standard-label">Theater</InputLabel>
        <Select
          labelId="demo-simple-select-standard-label"
          id="demo-simple-select-standard"
          value={theater}
          onChange={handleTheaterSelect}
          label="Theater"
        >
          {theaterList
            ? theaterList.map((item: any) => (
                <MenuItem key={item.pk} value={item.address}>
                  {item.address}
                </MenuItem>
              ))
            : null}
        </Select>
      </FormControl>
    </CustomContainer>
  );
};

export default LocationMenu;
