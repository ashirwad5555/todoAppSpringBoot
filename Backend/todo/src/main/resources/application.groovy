@Grab("spring-boot-starter-data-mongodb")
@Grab("spring-boot-starter-web")

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.MongoTemplate
import org.springframework.data.mongodb.core.mapping.Document
import org.springframework.data.mongodb.core.query.Query
import org.springframework.web.bind.annotation.*

@RestController
@CrossOrigin(origins = "*")
class TodoController {
    @Autowired
    private MongoTemplate mongo

    @GetMapping("/api/todos")
    def getTodos() {
        return mongo.findAll(Todo.class)
    }

    @PostMapping("/api/todos")
    def addTodo(@RequestBody Todo todo) {
        todo.createdAt = new Date()
        todo.updatedAt = new Date()
        return mongo.save(todo)
    }

    @GetMapping("/api/todos/{id}")
    def getTodo(@PathVariable String id) {
        return mongo.findById(id, Todo.class)
    }

    @PutMapping("/api/todos/{id}")
    def updateTodo(@PathVariable String id, @RequestBody Todo todoDetails) {
        Todo todo = mongo.findById(id, Todo.class)
        if (todo != null) {
            todo.title = todoDetails.title
            todo.isDone = todoDetails.isDone
            todo.updatedAt = new Date()
            return mongo.save(todo)
        }
        return null
    }

    @DeleteMapping("/api/todos/{id}")
    def deleteTodo(@PathVariable String id) {
        Todo todo = mongo.findById(id, Todo.class)
        if (todo != null) {
            mongo.remove(todo)
            return [status: "ok", message: "Todo deleted"]
        }
        return [status: "error", message: "Todo not found"]
    }

    @DeleteMapping("/api/todos")
    def clearTodos() {
        mongo.remove(new Query(), Todo.class)
        return [status: "ok", message: "All todos deleted"]
    }
}

@Document(collection = "todos")
class Todo {
    @Id
    String id
    String title
    boolean isDone
    Date createdAt
    Date updatedAt
}