# Platform Validation Guide

## Purpose

## Lab 1 Validation
    Operating System
    SELinux
    Podman

## Lab 2 Validation
    Quadlets
    Network
    Deployment

## Lab 3 Validation
    Grafana
    Volumes
    Internal Network
    Published Ports

## Lab 4 Validation
    Prometheus
    Targets
    Grafana Data Source

## Full Platform Validation

##Lab1-3
hostnamectl
getenforce
podman ps
podman network inspect noc
systemctl status grafana.service
curl http://192.168.3.12:3001/api/health

## Expected Results

