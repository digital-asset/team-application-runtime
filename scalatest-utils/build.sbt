// Copyright (c) 2022 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
// SPDX-License-Identifier: Apache-2.0

ThisBuild / scalaVersion := "2.13.8"
ThisBuild / organization := "com.daml"
ThisBuild / organizationName := "Digital Asset"
ThisBuild / licenses := Seq("Apache-2.0" -> url("http://www.apache.org/licenses/LICENSE-2.0.html"))
ThisBuild / homepage := Some(url("https://docs.daml.com"))

// Setting version to bypass sbt-dynver (and control version string format)
ThisBuild / version := sys.env.get("VERSION").getOrElse("local")

sonatypeCredentialHost := "s01.oss.sonatype.org"
sonatypeRepository := "https://s01.oss.sonatype.org/service/local"
// Note: the built-in `developers` list does not contain the same information
// we published from the daml repo; manually setting for consistency
pomExtra := <developers>
    <developer>
      <name>Digital Asset SDK Feedback</name>
      <email>sdk-feedback@digitalasset.com</email>
      <organization>Digital Asset (Switzerland) GmbH</organization>
      <organizationUrl>https://www.digitalasset.com/developers</organizationUrl>
    </developer>
  </developers>

lazy val root = (project in file("."))
  .settings(
    name := "scalatest-utils",
    libraryDependencies ++= Seq(
      "org.scalacheck" %% "scalacheck" % "1.15.4",
      "org.scalactic" %% "scalactic" % "3.2.9",
      "org.scalatest" %% "scalatest-core" % "3.2.9",
      "org.scalatest" % "scalatest-compatible" % "3.2.9",
      "org.scalatest" %% "scalatest-flatspec" % "3.2.9",
      "org.scalatest" %% "scalatest-matchers-core" % "3.2.9",
      "org.scalatest" %% "scalatest-shouldmatchers" % "3.2.9",
      "org.scalatest" %% "scalatest-wordspec" % "3.2.9",
      "org.scalatestplus" %% "scalacheck-1-15" % "3.2.9.0",
      "org.scalaz" %% "scalaz-core" % "7.2.33",
    ),
    addCompilerPlugin("org.typelevel" % "kind-projector" % "0.13.2" cross CrossVersion.full),
  )

// TODO: See https://www.scala-sbt.org/1.x/docs/Using-Sonatype.html for instructions on how to publish to Sonatype.
