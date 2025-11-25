package com.bookstore.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.entity.Distributor;
import com.bookstore.repository.DistributorRepository;
import com.bookstore.service.DistributorService;
import org.springframework.stereotype.Service;

@Service
public class DistributorServiceImpl extends ServiceImpl<DistributorRepository, Distributor> implements DistributorService {
}
