package com.spring_boot_mongodb.todo.repository;

import com.spring_boot_mongodb.todo.model.Todo;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TodoRepository extends MongoRepository<Todo, String> {
    // Additional custom queries can be added here if needed
}