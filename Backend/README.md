# BookStore Backend

This is the backend service for the BookStore App, built with Spring Boot, MyBatis-Plus, and MySQL.

## Prerequisites

- JDK 17+
- Maven 3.6+
- MySQL 8.0+

## Setup

1.  **Database Setup**:
    - Create a database named `bookstore_db`.
    - Run `src/main/resources/db/schema.sql` to create tables.
    - Run `src/main/resources/db/data.sql` to insert initial data.
    - Update `src/main/resources/application.yml` with your MySQL username and password.

2.  **Build**:
    ```bash
    mvn clean package
    ```

3.  **Run**:
    ```bash
    java -jar target/backend-0.0.1-SNAPSHOT.jar
    ```

## API Endpoints

### Auth
- `POST /api/v1/auth/login`: Login
- `POST /api/v1/auth/register`: Register

### User
- `GET /api/v1/users/profile`: Get current user profile
- `GET /api/v1/users/bookshelf`: Get user's bookshelf
- `POST /api/v1/users/bookshelf`: Add book to bookshelf
- `DELETE /api/v1/users/bookshelf`: Remove book from bookshelf
- `POST /api/v1/users/wallet/topup`: Top up coins (Mock)
- `POST /api/v1/users/membership/subscribe`: Subscribe SVIP (Mock)

### Books
- `GET /api/v1/books/home`: Get home page books (Hot, New, Free)
- `GET /api/v1/books/{id}`: Get book details
- `GET /api/v1/books/{id}/chapters`: Get book chapters
- `GET /api/v1/books/chapters/{id}`: Get chapter content
- `GET /api/v1/books/search?keyword=...`: Search books
