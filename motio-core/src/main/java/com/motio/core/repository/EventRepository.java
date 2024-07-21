package com.motio.core.repository;

import com.motio.commons.model.Event;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {

    @Cacheable(value = "events", key = "#id")
    Optional<Event> findById(Long id);

    @CachePut(value = "events", key = "#result.id")
    @Override
    <S extends Event> S save(S entity);

    @CacheEvict(value = "events", key = "#entity.id")
    @Override
    void delete(Event entity);
}
