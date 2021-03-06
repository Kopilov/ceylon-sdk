"Provides [[CeylonRepository]] for use with Spring Data.

 Your repository should satisfy `CeylonRepository`, for
 example:

     shared interface OrgRepository
             satisfies CeylonRepository<Org,Integer> {}

 Then, enable [[CeylonRepositoryImpl]] by annotating your
 `configuration` or `springBootApplication` class like
 this:

     springBootApplication
     enableJpaRepositories {
         repositoryBaseClass
             = `class CeylonRepositoryImpl`;
     }
     shared class MySpringApplication() {}"
by("Gavin King")
native("jvm")
see (`interface CeylonRepository`)
module ceylon.interop.spring maven:"org.ceylon-lang" "1.3.4-SNAPSHOT" {
    shared import java.base "7";

    shared import maven:org.springframework.data:"spring-data-commons" "1.13.6.RELEASE";
    shared import maven:org.springframework.data:"spring-data-jpa" "1.11.6.RELEASE";
    shared import maven:org.springframework:"spring-tx" "4.3.10.RELEASE";

    shared import maven:org.hibernate.javax.persistence:"hibernate-jpa-2.1-api" "1.0.0.Final";
}
