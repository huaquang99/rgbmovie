package com.rgbmovie.service.impl;

import com.rgbmovie.model.TheaterModel;
import com.rgbmovie.repository.TheaterRepository;
import com.rgbmovie.service.TheaterService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TheaterServiceImpl implements TheaterService {
    @Autowired
    private TheaterRepository theaterRepository;

    @Override
    public List<TheaterModel> getAll() {
        return theaterRepository.findAll();
    }

    @Override
    public TheaterModel getById(int pk) {
        return theaterRepository.getReferenceById(pk);
    }

    @Override
    public int numberOfStaff(int pk) {
        return theaterRepository.countByWorkplacesByPk(pk) != 0 ? theaterRepository.countByWorkplacesByPk(pk) : 0;
    }

    @Override
    public TheaterModel addNew(TheaterModel theaterModel) {
        return theaterRepository.saveAndFlush(theaterModel);
    }

    @Override
    public void deleteTheater(int id) {
        try {
            theaterRepository.deleteById(id);
        } catch (EntityNotFoundException e) {
            throw new EntityNotFoundException(e.getMessage());
        }
    }

}
