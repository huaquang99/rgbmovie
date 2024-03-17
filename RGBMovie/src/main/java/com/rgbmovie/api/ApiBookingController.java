package com.rgbmovie.api;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.rgbmovie.dto.ReservationDTO;
import com.rgbmovie.dto.ReservedSeatDTO;
import com.rgbmovie.model.MovieModel;
import com.rgbmovie.model.ReservationModel;
import com.rgbmovie.model.ReservedSeatModel;
import com.rgbmovie.model.ScreeningModel;
import com.rgbmovie.service.*;

import jakarta.persistence.criteria.CriteriaBuilder.In;
import net.minidev.json.annotate.JsonIgnore;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.nio.file.Path;
import java.util.*;

@RestController
@RequestMapping("/api/customer")
public class ApiBookingController {
    @Autowired
    private UserService userService;
    @Autowired
    private ReservationService reservationService;
    @Autowired
    private SeatService seatService;
    @Autowired
    private ReservedSeatService reservedSeatService;
    @Autowired
    private ScreeningService screeningService;
    @Autowired
    private MovieService movieService;

    @Autowired
    private ModelMapper modelMapper;

    @RequestMapping(value = "/book", method = RequestMethod.POST)
    public Object booking(@RequestParam("username") String username, @RequestParam("screening") int screening,
                          @RequestParam("seatName") String[] seatName, @RequestParam("auditorium") int auditorium) {
        try {
            ScreeningModel screeningModel = screeningService.getbyId(screening);
            MovieModel movieModel = movieService.getById(screeningModel.getMovie());
            Double price = movieModel.getPrice() * seatName.length;
            ReservationModel reservationModel = reservationService.checkExistIfNotCreateNew(screening);
            //Update cart
            if (reservationModel.getTotalCost() > 0) {
                reservationService.deleteReservation(reservationModel.getPk());
                reservationModel = reservationService.checkExistIfNotCreateNew(screening);
            }
            reservationModel.setUser(userService.findByUsername(username).getPk());
            reservationModel.setTotalCost(reservationModel.getTotalCost() + price);
            reservationService.update(reservationModel);
            for (String seat : seatName) {
                ReservedSeatDTO reservedSeatDTO = new ReservedSeatDTO();
                reservedSeatDTO.setSeat(seatService.findBySeatNameAndAuditorium(auditorium, seat));
                reservedSeatDTO.setReservation(reservationModel.getPk());
                reservedSeatDTO.setScreening(screening);
                reservedSeatService.createNew(modelMapper.map(reservedSeatDTO, ReservedSeatModel.class));
            }
            return new ResponseEntity<>("You order have been placed successfully", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/book/cancel/{id}")
    public Object cancelSeat(@PathVariable("id") int id) {
        reservedSeatService.cancelSeat(id);
        return new ResponseEntity<>("Remove seat successfully", HttpStatus.OK);
    }

    @GetMapping("/book/{action}")
    public Object order(@RequestParam(value = "resId", required = false, defaultValue = "") String resId, @RequestParam("userId") String userId,
                        @PathVariable("action") String action) {
        List<Map<String, Object>> reservationDTO = reservationService.getAllByUser(Integer.parseInt(userId), action);
        if (action.equals("cancel")) {
            reservationService.deleteReservation(Integer.parseInt(resId));
            return new ResponseEntity<>("Cancel Successfully", HttpStatus.OK);
        }
        return !reservationDTO.isEmpty() ? new ResponseEntity<>(reservationDTO, HttpStatus.OK)
                : new ResponseEntity<>("No order history", HttpStatus.NO_CONTENT);
    }

    @GetMapping("/book/history/{Id}")
    public Object orderHistoryDetail(@PathVariable("Id") String Id) {
        int id = Integer.parseInt(Id);
        ReservationDTO reservationDTO = modelMapper.map(reservationService.getById(id), ReservationDTO.class);

        List<ReservedSeatDTO> reservedSeatDTOs = reservedSeatService.findByReservationId(id).stream()
                .map(m -> modelMapper.map(m, ReservedSeatDTO.class)).toList();

        Map<String, Object> response = new HashMap<>();
        if (reservationDTO != null) {
            response.put("Reservation", reservationDTO);
        }
        if (reservedSeatDTOs != null) {
            response.put("ReservedSeat", reservedSeatDTOs);
        }
        return !response.isEmpty() ? new ResponseEntity<>(response, HttpStatus.OK)
                : new ResponseEntity<>("No order history", HttpStatus.BAD_REQUEST);
    }

}
