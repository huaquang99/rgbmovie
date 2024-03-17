package com.rgbmovie.repository;

import com.rgbmovie.model.DirectorModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DirectorRepository extends JpaRepository<DirectorModel, Integer> {
}
