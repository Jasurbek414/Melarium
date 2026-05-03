package com.melarium.config;

import com.melarium.entity.User;
import com.melarium.enums.UserRole;
import com.melarium.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;

    @Override
    public void run(String... args) {
        if (userRepository.findByPhone("+998901234567").isEmpty()) {
            User admin = User.builder()
                    .phone("+998901234567")
                    .fullName("Super Admin")
                    .role(UserRole.ADMIN)
                    .isActive(true)
                    .isVerified(true)
                    .balance(BigDecimal.valueOf(1000000000L))
                    .build();
            userRepository.save(admin);
            log.info("Default ADMIN user created: +998901234567");
        }
    }
}
