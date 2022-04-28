import geb.spock.GebReportingSpec

import pages.app.EntryPage
import pages.app.ConfirmationPage
                 
import spock.lang.Unroll
import spock.lang.Narrative
import spock.lang.Title
import org.junit.Test
/

@Narrative('''Basic functionality test''')

@Title("Load the Containers Sample application, check some elements, interact with the DB")
class FirstTest extends GebReportingSpec {

  def "Go to Entry Page and verify the title" () {
    given: "Starting from the Entry Page"
        waitFor {to EntryPage}

        println Header1.text() 
        assert Header1.text() == "Simple Demo App"   //Check the title

    when: "Click on the Drop down to expand the drop down options, select #Greeting  and click Submit button"
        GreetingDropdown.click()
        $("li",'data-value':testGreeting).click()
        sleep(1000)
        waitFor{SubmitButton.click()}

    then: "verify we load the confimation page and Verify the Hello greeting appears in the Previous Greeting selection list"
       assert(waitFor{at ConfirmationPage})
       //sleep(300)
       assert waitFor{(MyGreeting.text().contains(testGreeting))}

    and: "Return to the Entry page by clicking the Confirmation button"
    waitFor{SubmitButton.click()}

    then: "Confirm we have arrived to the Entry page and confirm the current greeting and the previous one have been saved and it is displayed"    
        assert(waitFor{at EntryPage})
        sleep(1500)

        def PG2= waitFor{PreviousGreetings.$("tr")} //get all the rows

        def NewPG= []
            for (int i : (0..<PG2.size())) {
              NewPG << PG2[i].$("td")[0].text()+PG2[i].$("td")[1].text()+PG2[i].$("td")[2].text()
            } 
        NewPG.sort()


        def NewPGR =NewPG.sort().reverse()
          // for (int i : (0..<NewPGR.size())) {
          //     println NewPGR[i]
          // } 

        assert NewPGR[0].contains(testGreeting)
        if (iteration>1){
          assert NewPGR[1].contains(testPreviousGreeting)    
        }

    where:
       testGreeting      | testPreviousGreeting | iteration
       "Aloha"           | _                    | 1 
       "Hello"           | "Aloha"              | 2
       "Bonjour"         | "Hello"              | 3
       "Konichiwa"       | "Bonjour"            | 4
       "Howdy"           | "Konichiwa"          | 5

     }

}
