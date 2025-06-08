package com.spring_boot_mongodb.todo.service;

import com.spring_boot_mongodb.todo.model.Todo;
import com.spring_boot_mongodb.todo.repository.TodoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

//to run the spring boot backend : mvn spring-boot:run

@Service
public class TodoService {

    @Autowired
    private TodoRepository todoRepository;

    public List<Todo> getAllTodos() {
        return todoRepository.findAll(Sort.by(Sort.Direction.ASC, "position"));
    }

    public Todo createTodo(Todo todo) {
        // Get highest position and add 1
        int maxPosition = 0;
        List<Todo> todos = todoRepository.findAll();
        for (Todo t : todos) {
            if (t.getPosition() > maxPosition) {
                maxPosition = t.getPosition();
            }
        }
        todo.setPosition(maxPosition + 1);

        todo.setCreatedAt(new Date());
        todo.setUpdatedAt(new Date());
        return todoRepository.save(todo);
    }

    public Optional<Todo> getTodoById(String id) {
        return todoRepository.findById(id);
    }

    public Todo updateTodo(String id, Todo todoDetails) {
        Todo todo = todoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Todo not found with id: " + id));

        todo.setTitle(todoDetails.getTitle());
        todo.setDone(todoDetails.isDone());
        todo.setUpdatedAt(new Date());

        return todoRepository.save(todo);
    }

    public void deleteTodo(String id) {
        Todo todo = todoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Todo not found with id: " + id));
        todoRepository.delete(todo);
    }

    public void deleteAllTodos() {
        todoRepository.deleteAll();
    }

    public List<Todo> updatePositions(List<Todo> todos) {
        List<Todo> updatedTodos = new ArrayList<>();
        for (Todo todo : todos) {
            Todo existingTodo = todoRepository.findById(todo.getId())
                    .orElseThrow(() -> new RuntimeException("Todo not found with id: " + todo.getId()));
            existingTodo.setPosition(todo.getPosition());
            existingTodo.setUpdatedAt(new Date());
            updatedTodos.add(todoRepository.save(existingTodo));
        }
        return updatedTodos;
    }
}