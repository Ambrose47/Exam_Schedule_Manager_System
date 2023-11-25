package com.example.esms.repository;


import com.example.esms.entity.courseStudent.CourseStudent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CourseStudentFullRepository extends JpaRepository<CourseStudent, String> {
}